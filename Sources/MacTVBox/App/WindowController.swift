import AppKit
import IOKit.pwr_mgt

// ==================== 电视窗口与防休眠电源管理 ====================

public final class WindowController: ObservableObject {
    public static let shared = WindowController()
    
    private var sleepAssertionID: IOPMAssertionID = 0
    private var isAssertionActive: Bool = false
    
    private init() {}
    
    /// 开启防屏幕黑屏休眠断言 (防止看剧或长时间未动键鼠时息屏)
    public func preventScreenSleep() {
        guard !isAssertionActive else { return }
        
        let reason = "MacTVBox TV Player is playing media" as CFString
        let success = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &sleepAssertionID
        )
        
        if success == kIOReturnSuccess {
            isAssertionActive = true
            print("[MacTVBox] Screen sleep prevention activated.")
        }
    }
    
    /// 释放休眠抑制断言
    public func restoreScreenSleep() {
        guard isAssertionActive else { return }
        IOPMAssertionRelease(sleepAssertionID)
        isAssertionActive = false
        print("[MacTVBox] Screen sleep prevention released.")
    }
    
    /// 隐藏鼠标光标，营造纯手柄大屏控制体验
    public func hideMouseCursor() {
        NSCursor.setHiddenUntilMouseMoves(true)
    }
}
