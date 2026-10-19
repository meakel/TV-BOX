import Foundation

// ==================== 通用适配器与适配器工厂 ====================

public struct GenericWebAdapter: WebAdapter {
    public let channelType: ChannelType
    
    public init(channelType: ChannelType) {
        self.channelType = channelType
    }
    
    public var initializationScript: String {
        """
        console.log('[MacTVBox] Generic TV Adapter Active');
        """
    }
    
    public func scriptForAction(_ action: FocusAction) -> String? {
        switch action {
        case .confirm, .playPause:
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) { v.paused ? v.play() : v.pause(); }
            })();
            """
        case .right, .seekForward:
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) { v.currentTime = Math.min(v.duration, v.currentTime + 10); }
            })();
            """
        case .left, .seekBackward:
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) { v.currentTime = Math.max(0, v.currentTime - 10); }
            })();
            """
        case .up:
            return "window.scrollBy({ top: -300, behavior: 'smooth' });"
        case .down:
            return "window.scrollBy({ top: 300, behavior: 'smooth' });"
        default:
            return nil
        }
    }
}

public enum AdapterFactory {
    public static func makeAdapter(for channel: ChannelType) -> WebAdapter {
        switch channel {
        case .bilibili:
            return BilibiliAdapter()
        case .tencent:
            return TencentVideoAdapter()
        case .douyin:
            return DouyinAdapter()
        case .iqiyi, .youtubeTV:
            return GenericWebAdapter(channelType: channel)
        }
    }
}
