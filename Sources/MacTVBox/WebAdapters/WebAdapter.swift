import Foundation
import WebKit

// ==================== Web 流媒体大屏适配协议 ====================

public protocol WebAdapter {
    /// 适用的渠道类型
    var channelType: ChannelType { get }
    
    /// 注入页面的大屏优化 CSS
    var customCSS: String { get }
    
    /// 页面加载完成后注入的核心 JavaScript 适配引擎
    var initializationScript: String { get }
    
    /// 当接收到 Xbox 手柄动作时，生成要执行的 JS 指令
    func scriptForAction(_ action: FocusAction) -> String?
}

// 默认通用实现
public extension WebAdapter {
    var customCSS: String {
        """
        /* 隐藏滚动条但保留滚动能力，隐藏鼠标指针 */
        ::-webkit-scrollbar { display: none !important; }
        body {
            cursor: none !important;
            user-select: none !important;
            -webkit-user-select: none !important;
        }
        """
    }
}
