import SwiftUI
import WebKit

// ==================== WKWebView 沉浸式电视播放容器 ====================

public struct WebContainerView: NSViewRepresentable {
    public let channel: Channel
    @ObservedObject private var coordinator = FocusCoordinator.shared
    
    public init(channel: Channel) {
        self.channel = channel
    }
    
    public func makeCoordinator() -> WebCoordinator {
        WebCoordinator(channel: channel)
    }
    
    public func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // 允许媒体自动播放，无需鼠标点击手势
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.isElementFullscreenEnabled = true
        
        // 针对电视大屏定制的 UserAgent (仿最新 Mac Safari 大屏)
        configuration.applicationNameForUserAgent = "Version/17.4 Safari/605.1.15 MacTVBox/1.0"
        
        let adapter = AdapterFactory.makeAdapter(for: channel.id)
        
        // 注入大屏自适应 CSS
        let cssScript = """
        const style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = `\(adapter.customCSS)`;
        document.head.appendChild(style);
        """
        let userScriptCSS = WKUserScript(
            source: cssScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(userScriptCSS)
        
        // 注入初始化脚本
        let userScriptInit = WKUserScript(
            source: adapter.initializationScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(userScriptInit)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        
        // 绑定动作派发
        coordinator.onDispatchWebAction = { [weak webView] action in
            guard let webView = webView else { return }
            if let js = adapter.scriptForAction(action) {
                webView.evaluateJavaScript(js) { _, error in
                    if let error = error {
                        print("[MacTVBox] JS Exec Error: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        let request = URLRequest(url: channel.url)
        webView.load(request)
        
        return webView
    }
    
    public func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    public final class WebCoordinator: NSObject, WKNavigationDelegate {
        public let channel: Channel
        public weak var webView: WKWebView?
        
        public init(channel: Channel) {
            self.channel = channel
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("[MacTVBox] Loaded \(channel.title)")
        }
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("[MacTVBox] Failed to load \(channel.title): \(error.localizedDescription)")
        }
    }
}
