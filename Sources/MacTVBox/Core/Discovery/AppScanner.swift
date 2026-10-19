import AppKit
import Foundation

// ==================== 已安装本地 macOS 软件模型 ====================

public struct InstalledApp: Identifiable, Equatable, Hashable {
    public let id: String                 // bundleIdentifier 或 路径
    public let name: String               // 应用显示名称
    public let bundleURL: URL             // .app 路径
    public let bundleIdentifier: String?  // com.xxx.yyy
    public let icon: NSImage              // 应用原生高清图标
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: InstalledApp, rhs: InstalledApp) -> Bool {
        lhs.id == rhs.id
    }
}

// ==================== macOS 本地应用自动发现引擎 ====================

public final class AppScanner: ObservableObject {
    public static let shared = AppScanner()
    
    @Published public private(set) var installedApps: [InstalledApp] = []
    @Published public private(set) var isScanning: Bool = false
    
    private init() {
        scanApplications()
    }
    
    /// 异步扫描系统各层级中的 .app 应用程序
    public func scanApplications() {
        isScanning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var apps: [InstalledApp] = []
            let fileManager = FileManager.default
            
            // 扫描路径集合：系统应用、通用应用、用户独立应用
            var searchDirectories: [URL] = [
                URL(fileURLWithPath: "/Applications"),
                URL(fileURLWithPath: "/System/Applications")
            ]
            
            if let userApps = fileManager.urls(for: .applicationDirectory, in: .userDomainMask).first {
                searchDirectories.append(userApps)
            }
            
            var seenIdentifiers = Set<String>()
            
            for directory in searchDirectories {
                guard let enumerator = fileManager.enumerator(
                    at: directory,
                    includingPropertiesForKeys: [.isApplicationKey, .nameKey],
                    options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants]
                ) else { continue }
                
                for case let fileURL as URL in enumerator {
                    guard fileURL.pathExtension == "app" else { continue }
                    
                    // 过滤内部辅助程序与更新卸载程序
                    let fileName = fileURL.deletingPathExtension().lastPathComponent
                    let lowerName = fileName.lowercased()
                    if lowerName.contains("uninstall") ||
                       lowerName.contains("helper") ||
                       lowerName.contains("crash reporter") {
                        continue
                    }
                    
                    guard let bundle = Bundle(url: fileURL) else { continue }
                    let bundleId = bundle.bundleIdentifier ?? fileURL.path
                    
                    if seenIdentifiers.contains(bundleId) { continue }
                    seenIdentifiers.insert(bundleId)
                    
                    // 读取应用显示名
                    let displayName = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
                        ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
                        ?? fileName
                    
                    // 提取系统原生图标
                    let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
                    icon.size = NSSize(width: 256, height: 256)
                    
                    let app = InstalledApp(
                        id: bundleId,
                        name: displayName,
                        bundleURL: fileURL,
                        bundleIdentifier: bundle.bundleIdentifier,
                        icon: icon
                    )
                    apps.append(app)
                }
            }
            
            // 排序：将媒体、影音与游戏等优先排在前面，其余按字典序
            let sortedApps = apps.sorted { app1, app2 in
                let p1 = Self.priority(for: app1.name)
                let p2 = Self.priority(for: app2.name)
                if p1 != p2 { return p1 > p2 }
                return app1.name.localizedCompare(app2.name) == .orderedAscending
            }
            
            DispatchQueue.main.async {
                self?.installedApps = sortedApps
                self?.isScanning = false
                print("[MacTVBox] Successfully scanned \(sortedApps.count) installed applications.")
            }
        }
    }
    
    /// 原生拉起已安装的 macOS 应用程序
    public func launch(app: InstalledApp, completion: ((Bool) -> Void)? = nil) {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        
        NSWorkspace.shared.openApplication(at: app.bundleURL, configuration: config) { runningApp, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[MacTVBox] Failed to launch \(app.name): \(error.localizedDescription)")
                    completion?(false)
                } else {
                    print("[MacTVBox] Launched native app \(app.name) (PID: \(runningApp?.processIdentifier ?? 0))")
                    completion?(true)
                }
            }
        }
    }
    
    // 影音/娱乐/常用工具优先权重
    private static func priority(for name: String) -> Int {
        let key = name.lowercased()
        if key.contains("iina") || key.contains("vlc") || key.contains("infuse") { return 100 }
        if key.contains("music") || key.contains("网易云") || key.contains("qq音乐") { return 90 }
        if key.contains("steam") || key.contains("play") || key.contains("game") { return 85 }
        if key.contains("safari") || key.contains("chrome") { return 70 }
        return 0
    }
}
