import Foundation
import GameController
import Combine

// ==================== Xbox 手柄管理器 ====================

/// 负责监听 macOS 系统连接的 Xbox 蓝牙/有线手柄
/// 通过 GameController 框架读取输入并防抖转化为 FocusAction
public final class GamepadManager: ObservableObject {
    public static let shared = GamepadManager()
    
    @Published public private(set) var isConnected: Bool = false
    @Published public private(set) var controllerName: String = "未连接手柄"
    
    // 动作分发回调
    public var onAction: ((FocusAction) -> Void)?
    
    private var activeController: GCController?
    private var lastDirectionTime: Date = .distantPast
    private let repeatThreshold: TimeInterval = 0.22 // 摇杆长推时的步进延迟
    private let deadzone: Float = 0.45             // 摇杆死区阈值
    
    private init() {
        setupNotifications()
        checkForExistingControllers()
    }
    
    // MARK: - 连接监听
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleControllerConnected(_:)),
            name: .GCControllerDidConnect,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleControllerDisconnected(_:)),
            name: .GCControllerDidDisconnect,
            object: nil
        )
    }
    
    private func checkForExistingControllers() {
        if let first = GCController.controllers().first {
            configure(controller: first)
        }
    }
    
    @objc private func handleControllerConnected(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        configure(controller: controller)
    }
    
    @objc private func handleControllerDisconnected(_ notification: Notification) {
        guard let controller = notification.object as? GCController,
              controller == activeController else { return }
        
        DispatchQueue.main.async {
            self.activeController = nil
            self.isConnected = false
            self.controllerName = "未连接手柄"
        }
    }
    
    // MARK: - 手柄配置与按键绑定
    private func configure(controller: GCController) {
        self.activeController = controller
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.controllerName = controller.vendorName ?? "Xbox 无线控制器"
        }
        
        guard let gamepad = controller.extendedGamepad else { return }
        
        // 1. 十字键 (D-Pad)
        gamepad.dpad.up.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.up) }
        }
        gamepad.dpad.down.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.down) }
        }
        gamepad.dpad.left.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.left) }
        }
        gamepad.dpad.right.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.right) }
        }
        
        // 2. 左摇杆模拟方向（带死区与重复触发控制）
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
            self?.handleThumbstick(x: x, y: y)
        }
        
        // 3. ABXY 核心功能键
        // Xbox A 键 -> 确认 / 播放暂停
        gamepad.buttonA.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.confirm) }
        }
        
        // Xbox B 键 -> 返回
        gamepad.buttonB.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.back) }
        }
        
        // Xbox X 键 -> 全屏控制 / 备用动作
        gamepad.buttonX.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.actionX) }
        }
        
        // Xbox Y 键 -> 打开/隐藏帮助 HUD
        gamepad.buttonY.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.actionY) }
        }
        
        // 4. 肩键与扳机键 (LB / RB / LT / RT)
        gamepad.leftShoulder.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.prevVideo) }
        }
        
        gamepad.rightShoulder.pressedChangedHandler = { [weak self] _, _, pressed in
            if pressed { self?.dispatch(.nextVideo) }
        }
        
        gamepad.leftTrigger.pressedChangedHandler = { [weak self] _, value, pressed in
            if pressed && value > 0.5 { self?.dispatch(.seekBackward) }
        }
        
        gamepad.rightTrigger.pressedChangedHandler = { [weak self] _, value, pressed in
            if pressed && value > 0.5 { self?.dispatch(.seekForward) }
        }
    }
    
    // MARK: - 摇杆防抖与离散化
    private func handleThumbstick(x: Float, y: Float) {
        let now = Date()
        guard now.timeIntervalSince(lastDirectionTime) > repeatThreshold else { return }
        
        if y > deadzone {
            dispatch(.up)
            lastDirectionTime = now
        } else if y < -deadzone {
            dispatch(.down)
            lastDirectionTime = now
        } else if x > deadzone {
            dispatch(.right)
            lastDirectionTime = now
        } else if x < -deadzone {
            dispatch(.left)
            lastDirectionTime = now
        }
    }
    
    private func dispatch(_ action: FocusAction) {
        DispatchQueue.main.async { [weak self] in
            self?.onAction?(action)
        }
    }
}
