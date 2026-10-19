import Foundation
import Combine
import SwiftUI

// ==================== 电视盒子全局焦点与状态机 ====================

public enum AppState: Equatable {
    case launcher
    case inApp(Channel)
}

public final class FocusCoordinator: ObservableObject {
    public static let shared = FocusCoordinator()
    
    @Published public var currentAppState: AppState = .launcher
    @Published public var selectedCategory: LauncherCategory = .all
    @Published public var focusedIndex: Int = 0
    @Published public var showHUD: Bool = false
    
    // 当前页面分发 JS 动作的闭包
    public var onDispatchWebAction: ((FocusAction) -> Void)?
    
    // 数据源
    private var cancellables = Set<AnyCancellable>()
    @Published public private(set) var allItems: [LauncherItem] = []
    
    public let columnsCount: Int = 4 // 每行显示的卡片列数
    
    private init() {
        setupDataSources()
        
        // 绑定手柄动作输入
        GamepadManager.shared.onAction = { [weak self] action in
            self?.handleAction(action)
        }
    }
    
    // MARK: - 数据源整合
    private func setupDataSources() {
        // 先加载内置流媒体渠道
        let presetItems = Channel.presetChannels.map { LauncherItem(channel: $0) }
        self.allItems = presetItems
        
        // 监听本地应用扫描完成并动态合并
        AppScanner.shared.$installedApps
            .receive(on: DispatchQueue.main)
            .sink { [weak self] localApps in
                guard let self = self else { return }
                let localItems = localApps.map { LauncherItem(app: $0) }
                self.allItems = presetItems + localItems
            }
            .store(in: &cancellables)
    }
    
    /// 当前分类过滤后的应用项
    public var currentItems: [LauncherItem] {
        switch selectedCategory {
        case .all:
            return allItems
        case .media:
            return allItems.filter { $0.category == .media }
        case .localApps:
            return allItems.filter { $0.category == .localApps }
        }
    }
    
    /// 当前聚焦的应用项
    public var focusedItem: LauncherItem? {
        let items = currentItems
        guard !items.isEmpty, focusedIndex >= 0, focusedIndex < items.count else { return nil }
        return items[focusedIndex]
    }
    
    // MARK: - 动作路由分发
    public func handleAction(_ action: FocusAction) {
        // 全局 Y 键：切换手柄指南 HUD
        if action == .actionY {
            showHUD.toggle()
            return
        }
        
        switch currentAppState {
        case .launcher:
            handleLauncher2DGridAction(action)
            
        case .inApp:
            handleInAppAction(action)
        }
    }
    
    // MARK: - Apple TV 2D 网格空间焦点导航
    private func handleLauncher2DGridAction(_ action: FocusAction) {
        let itemsCount = currentItems.count
        guard itemsCount > 0 else { return }
        
        switch action {
        case .left:
            if focusedIndex > 0 {
                focusedIndex -= 1
            }
            
        case .right:
            if focusedIndex < itemsCount - 1 {
                focusedIndex += 1
            }
            
        case .up:
            // 向上移动一行
            if focusedIndex - columnsCount >= 0 {
                focusedIndex -= columnsCount
            }
            
        case .down:
            // 向下移动一行
            if focusedIndex + columnsCount < itemsCount {
                focusedIndex += columnsCount
            } else if focusedIndex < itemsCount - 1 {
                // 如果刚好最后一行缺列，平滑移至最后项
                focusedIndex = itemsCount - 1
            }
            
        case .actionX:
            // X 键快速轮换分类标签 (全部 -> 精选流媒体 -> 本地软件)
            cycleCategory()
            
        case .confirm:
            if let target = focusedItem {
                launchItem(target)
            }
            
        default:
            break
        }
    }
    
    // 切换分类标签
    public func selectCategory(_ category: LauncherCategory) {
        selectedCategory = category
        focusedIndex = 0
    }
    
    private func cycleCategory() {
        let allCategories = LauncherCategory.allCases
        if let idx = allCategories.firstIndex(of: selectedCategory) {
            let nextIdx = (idx + 1) % allCategories.count
            selectCategory(allCategories[nextIdx])
        }
    }
    
    // MARK: - 启动应用
    public func launchItem(_ item: LauncherItem) {
        switch item.payload {
        case .webChannel(let channel):
            currentAppState = .inApp(channel)
            
        case .nativeApp(let app):
            AppScanner.shared.launch(app: app)
        }
    }
    
    // MARK: - 播放器内交互
    private func handleInAppAction(_ action: FocusAction) {
        // Xbox B 键：退出当前播放器，瞬间返回 Apple TV 风格主屏
        if action == .back {
            currentAppState = .launcher
            return
        }
        
        // 将事件转发给 WebKit 适配器
        onDispatchWebAction?(action)
    }
}
