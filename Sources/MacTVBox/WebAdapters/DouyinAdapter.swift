import Foundation

// ==================== 抖音大屏短视频手柄适配器 ====================

public struct DouyinAdapter: WebAdapter {
    public let channelType: ChannelType = .douyin
    
    public var customCSS: String {
        """
        ::-webkit-scrollbar { display: none !important; }
        body {
            cursor: none !important;
            user-select: none !important;
            background-color: #000000 !important;
            overflow: hidden !important;
        }
        /* 屏蔽顶栏、右侧杂乱功能菜单、客户端下载提示、登录强制浮窗 */
        #douyin-header, .login-mask-enter-done, .download-guide-container, .side-navigation {
            display: none !important;
        }
        /* 让视频区域完全自适应屏幕居中显示 */
        .video-card-container, .slide-list {
            margin: 0 auto !important;
            width: 100vw !important;
            height: 100vh !important;
        }
        """
    }
    
    public var initializationScript: String {
        """
        (function() {
            console.log('[MacTVBox] Douyin TV Controller Adapter Initialized');
            
            // 自动关闭初始弹窗或提示
            setInterval(function() {
                const closeBtn = document.querySelector('.dy-account-close, .modal-close');
                if (closeBtn) closeBtn.click();
            }, 1000);
            
            // 键盘模拟辅助
            window.dySendKey = function(key, code) {
                const event = new KeyboardEvent('keydown', {
                    key: key,
                    keyCode: code,
                    code: key,
                    bubbles: true,
                    cancelable: true
                });
                window.dispatchEvent(event);
                document.body.dispatchEvent(event);
            };
        })();
        """
    }
    
    public func scriptForAction(_ action: FocusAction) -> String? {
        switch action {
        case .down, .nextVideo:
            // 切换下一个短视频：触发 ArrowDown 键
            return """
            (function() {
                window.dySendKey('ArrowDown', 40);
                // 备用触发：查找抖音自带的“下一个视频”切换按钮
                const nextBtn = document.querySelector('.xgplayer-playswitch-next, .switch-item-down');
                if (nextBtn) nextBtn.click();
            })();
            """
            
        case .up, .prevVideo:
            // 切换上一个短视频：触发 ArrowUp 键
            return """
            (function() {
                window.dySendKey('ArrowUp', 38);
                const prevBtn = document.querySelector('.xgplayer-playswitch-prev, .switch-item-up');
                if (prevBtn) prevBtn.click();
            })();
            """
            
        case .confirm, .playPause:
            // 暂停 / 播放
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) {
                    v.paused ? v.play() : v.pause();
                } else {
                    window.dySendKey(' ', 32);
                }
            })();
            """
            
        case .right, .seekForward:
            // 快进 5 秒
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) { v.currentTime = Math.min(v.duration, v.currentTime + 5); }
            })();
            """
            
        case .left, .seekBackward:
            // 快退 5 秒
            return """
            (function() {
                const v = document.querySelector('video');
                if (v) { v.currentTime = Math.max(0, v.currentTime - 5); }
            })();
            """
            
        case .actionX:
            // 点赞当前视频 (Xbox X 键)
            return """
            (function() {
                const likeBtn = document.querySelector('.action-item.like, [data-e2e="feed-like-icon"]');
                if (likeBtn) likeBtn.click();
            })();
            """
            
        default:
            return nil
        }
    }
}
