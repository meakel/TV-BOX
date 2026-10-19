import SwiftUI

// ==================== Apple TV 风格电视主屏启动器 ====================

public struct LauncherView: View {
    @ObservedObject private var coordinator = FocusCoordinator.shared
    @ObservedObject private var gamepad = GamepadManager.shared
    @ObservedObject private var scanner = AppScanner.shared
    
    @State private var currentTimeString: String = ""
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // 4 列自适应网格
    private let columns = [
        GridItem(.flexible(), spacing: 28),
        GridItem(.flexible(), spacing: 28),
        GridItem(.flexible(), spacing: 28),
        GridItem(.flexible(), spacing: 28)
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // 背景底色：深空黑与微光晕
            Color(red: 0.05, green: 0.05, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. 顶栏：时间、本地软件扫描状态与 Xbox 手柄状态
                topStatusBar
                    .padding(.horizontal, 48)
                    .padding(.top, 24)
                    .zIndex(2)
                
                // 2. Apple TV 沉浸式 Top Shelf 展架
                TopShelfView(item: coordinator.focusedItem)
                    .zIndex(1)
                
                // 3. 分类切换标签栏 (全部 / 流媒体 / 本地应用)
                categoryTabsBar
                    .padding(.horizontal, 48)
                    .padding(.bottom, 20)
                
                // 4. 下方 2D 空间卡片网格
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEach(Array(coordinator.currentItems.enumerated()), id: \.element.id) { index, item in
                                AppCardView(
                                    item: item,
                                    isFocused: coordinator.focusedIndex == index
                                )
                                .id(index)
                                .onTapGesture {
                                    coordinator.focusedIndex = index
                                    coordinator.launchItem(item)
                                }
                            }
                        }
                        .padding(.horizontal, 56)
                        .padding(.bottom, 60)
                    }
                    .onChange(of: coordinator.focusedIndex) { newIndex in
                        withAnimation(.easeInOut(duration: 0.22)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                
                // 5. 底栏：Xbox 手柄按键指引
                bottomFooterBar
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    .background(Color.black.opacity(0.4))
            }
            
            // 手柄指南浮层
            if coordinator.showHUD {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture { coordinator.showHUD = false }
                
                OverlayHUDView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onReceive(timer) { _ in
            updateTime()
        }
        .onAppear {
            updateTime()
        }
    }
    
    // MARK: - 顶栏状态
    private var topStatusBar: some View {
        HStack {
            Text(currentTimeString)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if scanner.isScanning {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("正在同步 Mac 本地应用...")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.leading, 12)
            }
            
            Spacer()
            
            // Xbox 控制器连接指示器
            HStack(spacing: 8) {
                Circle()
                    .fill(gamepad.isConnected ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                Image(systemName: "gamecontroller.fill")
                    .foregroundColor(gamepad.isConnected ? .white : .orange)
                    .font(.system(size: 14))
                
                Text(gamepad.isConnected ? gamepad.controllerName : "请连接 Xbox 蓝牙手柄")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            )
        }
    }
    
    // MARK: - 分类导航标签
    private var categoryTabsBar: some View {
        HStack(spacing: 16) {
            ForEach(LauncherCategory.allCases) { cat in
                let isSelected = coordinator.selectedCategory == cat
                Button(action: {
                    coordinator.selectCategory(cat)
                }) {
                    Text(cat.rawValue)
                        .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .black : .white.opacity(0.75))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(isSelected ? Color.white : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            Text("按 (X) 快速轮换分类")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
        }
    }
    
    // MARK: - 底栏按键提示
    private var bottomFooterBar: some View {
        HStack(spacing: 28) {
            keyPrompt(button: "A", color: .green, text: "打开应用")
            keyPrompt(button: "B", color: .red, text: "退出播放")
            keyPrompt(button: "X", color: .blue, text: "切换分类")
            keyPrompt(button: "Y", color: .yellow, text: "手柄指南")
            
            Spacer()
            
            Text("左摇杆 / 十字键 上下左右 2D 焦点移动")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.45))
        }
    }
    
    private func keyPrompt(button: String, color: Color, text: String) -> some View {
        HStack(spacing: 7) {
            Text(button)
                .font(.system(size: 12, weight: .black))
                .foregroundColor(.black)
                .frame(width: 20, height: 20)
                .background(Circle().fill(color))
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTimeString = formatter.string(from: Date())
    }
}
