import Foundation
import SwiftUI

// ==================== 电视盒子预置流媒体渠道 ====================

public enum ChannelType: String, CaseIterable, Identifiable {
    case bilibili
    case tencent
    case douyin
    case iqiyi
    case youtubeTV
    
    public var id: String { rawValue }
}

public struct Channel: Identifiable, Hashable {
    public let id: ChannelType
    public let title: String
    public let subtitle: String
    public let url: URL
    public let iconSymbol: String
    public let brandColor: Color
    public let secondaryColor: Color
    
    public static let presetChannels: [Channel] = [
        Channel(
            id: .bilibili,
            title: "哔哩哔哩",
            subtitle: "你感兴趣的视频都在 B站",
            url: URL(string: "https://www.bilibili.com")!,
            iconSymbol: "tv.fill",
            brandColor: Color(red: 0.98, green: 0.44, blue: 0.60), // B站粉
            secondaryColor: Color(red: 0.14, green: 0.67, blue: 0.88)
        ),
        Channel(
            id: .tencent,
            title: "腾讯视频",
            subtitle: "热播大剧 · 独播综艺 · 院线电影",
            url: URL(string: "https://v.qq.com")!,
            iconSymbol: "play.tv.fill",
            brandColor: Color(red: 1.00, green: 0.45, blue: 0.05), // 腾讯橙
            secondaryColor: Color(red: 0.05, green: 0.55, blue: 0.95)
        ),
        Channel(
            id: .douyin,
            title: "抖音",
            subtitle: "手柄上下刷视频 · 沉浸大屏模式",
            url: URL(string: "https://www.douyin.com")!,
            iconSymbol: "video.badge.waveform.fill",
            brandColor: Color(red: 0.11, green: 0.11, blue: 0.14), // 抖音黑底霓虹
            secondaryColor: Color(red: 0.13, green: 0.89, blue: 0.88)
        ),
        Channel(
            id: .iqiyi,
            title: "爱奇艺",
            subtitle: "海量超清视听体验",
            url: URL(string: "https://www.iqiyi.com")!,
            iconSymbol: "sparkles.tv.fill",
            brandColor: Color(red: 0.00, green: 0.75, blue: 0.35), // 爱奇艺绿
            secondaryColor: Color(red: 0.00, green: 0.45, blue: 0.20)
        ),
        Channel(
            id: .youtubeTV,
            title: "YouTube TV",
            subtitle: "原生 10-foot 大屏界面体验",
            url: URL(string: "https://www.youtube.com/tv")!,
            iconSymbol: "play.rectangle.fill",
            brandColor: Color(red: 0.95, green: 0.15, blue: 0.15),
            secondaryColor: Color(red: 0.40, green: 0.05, blue: 0.05)
        )
    ]
}
