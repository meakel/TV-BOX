import AppKit
import SwiftUI

// ==================== 统一启动项抽象模型 ====================

public enum LauncherCategory: String, CaseIterable, Identifiable {
    case all = "全部应用"
    case media = "精选流媒体"
    case localApps = "电脑本地软件"
    
    public var id: String { rawValue }
}

public enum LauncherItemPayload: Equatable {
    case webChannel(Channel)
    case nativeApp(InstalledApp)
}

public struct LauncherItem: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let category: LauncherCategory
    public let payload: LauncherItemPayload
    public let customIcon: NSImage?
    public let symbolIcon: String?
    public let brandColor: Color
    public let secondaryColor: Color
    public let badgeText: String?
    
    // 初始化自流媒体渠道
    public init(channel: Channel) {
        self.id = "channel_\(channel.id.rawValue)"
        self.title = channel.title
        self.subtitle = channel.subtitle
        self.category = .media
        self.payload = .webChannel(channel)
        self.customIcon = nil
        self.symbolIcon = channel.iconSymbol
        self.brandColor = channel.brandColor
        self.secondaryColor = channel.secondaryColor
        self.badgeText = "TV 适配"
    }
    
    // 初始化自本地已安装应用
    public init(app: InstalledApp) {
        self.id = "app_\(app.id)"
        self.title = app.name
        self.subtitle = "本地应用 · \(app.bundleIdentifier ?? "macOS App")"
        self.category = .localApps
        self.payload = .nativeApp(app)
        self.customIcon = app.icon
        self.symbolIcon = nil
        self.brandColor = Color(red: 0.25, green: 0.28, blue: 0.35)
        self.secondaryColor = Color(red: 0.12, green: 0.14, blue: 0.18)
        self.badgeText = "Mac 本地"
    }
}
