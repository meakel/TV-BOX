import Foundation

// ==================== 哔哩哔哩大屏适配器 ====================

public struct BilibiliAdapter: WebAdapter {
    public let channelType: ChannelType = .bilibili
    
    public var customCSS: String {
        """
        /* 隐藏滚动条与多余干扰元素 */
        ::-webkit-scrollbar { display: none !important; }
        body {
            cursor: none !important;
            user-select: none !important;
            background-color: #121212 !important;
        }
        /* 屏蔽网页右下角反馈与广告插件栏 */
        .palette-button-wrap, .bili-footer, .ad-report, .pop-live-small-mode {
            display: none !important;
        }
        /* 放大视频列表卡片字体与间距，适应电视观看 */
        .bili-video-card__info--tit {
            font-size: 18px !important;
            line-height: 24px !important;
        }
        """
    }
    
    public var initializationScript: String {
        """
        (function() {
            console.log('[MacTVBox] Bilibili TV Adapter Initialized');
            
            // 自动侦测并尝试展开网页全屏
            function autoFullscreen() {
                const webFsBtn = document.querySelector('.bpx-btn-web-fullscreen, .bilibili-player-video-web-fullscreen');
                if (webFsBtn && !document.querySelector('.bpx-state-web-fullscreen')) {
                    webFsBtn.click();
                }
            }
            setInterval(autoFullscreen, 2000);
            
            // 注入通用键盘分发助手
            window.tvSimulateKey = function(key, keyCode) {
                const event = new KeyboardEvent('keydown', {
                    key: key,
                    keyCode: keyCode,
                    code: key,
                    which: keyCode,
                    bubbles: true,
                    cancelable: true
                });
                document.activeElement?.dispatchEvent(event) || window.dispatchEvent(event);
            };
        })();
        """
    }
    
    public func scriptForAction(_ action: FocusAction) -> String? {
        switch action {
        case .confirm, .playPause:
            // 空格键：播放/暂停
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) {
                    v.paused ? v.play() : v.pause();
                } else {
                    window.tvSimulateKey(' ', 32);
                }
            })();
            """
            
        case .seekForward, .right:
            // 快进 10 秒
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) {
                    v.currentTime = Math.min(v.duration, v.currentTime + 10);
                } else {
                    window.tvSimulateKey('ArrowRight', 39);
                }
            })();
            """
            
        case .seekBackward, .left:
            // 快退 10 秒
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) {
                    v.currentTime = Math.max(0, v.currentTime - 10);
                } else {
                    window.tvSimulateKey('ArrowLeft', 37);
                }
            })();
            """
            
        case .up:
            // 页面向上滚动或增加音量
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
            // 页面向下滚动或降低音量
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
            // 切换网页全屏 / 浏览器全屏
            return """
            (function() {
                const fsBtn = document.querySelector('.bpx-btn-fullscreen, .bilibili-player-video-btn-fullscreen');
                if (fsBtn) { fsBtn.click(); }
                else { window.tvSimulateKey('f', 70); }
            })();
            """
            
        case .nextVideo:
            // 下一集
            return """
            (function() {
                const nextBtn = document.querySelector('.bpx-btn-next');
                if (nextBtn) { nextBtn.click(); }
                else { window.tvSimulateKey(']', 221); }
            })();
            """
            
        case .prevVideo:
            // 上一集
            return """
            (function() {
                window.tvSimulateKey('[', 219);
            })();
            """
            
        default:
            return nil
        }
    }
}
