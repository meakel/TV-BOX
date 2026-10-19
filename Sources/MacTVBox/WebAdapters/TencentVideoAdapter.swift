import Foundation

// ==================== 腾讯视频大屏适配器 ====================

public struct TencentVideoAdapter: WebAdapter {
    public let channelType: ChannelType = .tencent
    
    public var customCSS: String {
        """
        ::-webkit-scrollbar { display: none !important; }
        body {
            cursor: none !important;
            user-select: none !important;
            background-color: #0f1115 !important;
        }
        /* 屏蔽网页浮动导航与广告推广 */
        .site_head, .quick_nav, .mod_vip_popup, .txp_ad {
            display: none !important;
        }
        """
    }
    
    public var initializationScript: String {
        """
        (function() {
            console.log('[MacTVBox] Tencent Video Adapter Initialized');
            
            // 尝试自动最大化播放器区域
            setInterval(function() {
                const webFs = document.querySelector('.txp_btn_fake');
                if (webFs && !document.querySelector('.txp_fake_fullscreen')) {
                    webFs.click();
                }
            }, 2500);
        })();
        """
    }
    
    public func scriptForAction(_ action: FocusAction) -> String? {
        switch action {
        case .confirm, .playPause:
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) {
                    v.paused ? v.play() : v.pause();
                } else {
                    const playBtn = document.querySelector('.txp_btn_play');
                    if (playBtn) playBtn.click();
                }
            })();
            """
            
        case .seekForward, .right:
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) { v.currentTime = Math.min(v.duration, v.currentTime + 15); }
            })();
            """
            
        case .seekBackward, .left:
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) { v.currentTime = Math.max(0, v.currentTime - 15); }
            })();
            """
            
        case .up:
            return """
            (function() {
                const v = document.querySelector('video');
                if (v && !v.paused) {
                    v.volume = Math.min(1.0, v.volume + 0.1);
                } else {
                    window.scrollBy({ top: -350, behavior: 'smooth' });
                }
            })();
            """
            
        case .down:
            return """
            (function() {
                const v = document.querySelector('video');
                if (v && !v.paused) {
                    v.volume = Math.max(0.0, v.volume - 0.1);
                } else {
                    window.scrollBy({ top: 350, behavior: 'smooth' });
                }
            })();
            """
            
        case .actionX:
            return """
            (function() {
                const fs = document.querySelector('.txp_btn_fullscreen');
                if (fs) fs.click();
            })();
            """
            
        case .nextVideo:
            return """
            (function() {
                const nextBtn = document.querySelector('.txp_btn_next');
                if (nextBtn) nextBtn.click();
            })();
            """
            
        default:
            return nil
        }
    }
}
