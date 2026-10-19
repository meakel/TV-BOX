import Foundation

// ==================== 统一手柄虚拟按键动作 ====================

/// 从硬件手柄输入中抽象出的高阶动作，解耦具体物理按键
public enum FocusAction: Equatable, Hashable {
    // 导航动作
    case up
    case down
    case left
    case right
    
    // 核心按钮
    case confirm      // Xbox A 键：进入/确定/播放暂停
    case back         // Xbox B 键：返回/退出全屏/退回主页
    case actionX      // Xbox X 键：网页全屏切换
    case actionY      // Xbox Y 键：显示/隐藏手柄键位 HUD
    
    // 媒体流控制（针对视频播放页）
    case playPause    // 播放/暂停
    case seekForward  // 快进
    case seekBackward // 快退
    case nextVideo    // 切换下一个视频/下一集（如抖音下滑、B站下一P）
    case prevVideo    // 切换上一个视频/上一集（如抖音上滑、B站上一P）
    case volumeUp     // 音量加
    case volumeDown   // 音量减
}
