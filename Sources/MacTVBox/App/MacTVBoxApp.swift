import SwiftUI
import AppKit

// ==================== 应用主入口 ====================

@main
struct MacTVBoxApp: App {
    @StateObject private var coordinator = FocusCoordinator.shared
    @StateObject private var gamepad = GamepadManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootContentView()
                .preferredColorScheme(.dark)
                .frame(minWidth: 1280, minHeight: 720)
                .onAppear {
                    WindowController.shared.preventScreenSleep()
                    WindowController.shared.hideMouseCursor()
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

// ==================== 根视图与状态切换 ====================

struct RootContentView: View {
    @ObservedObject private var coordinator = FocusCoordinator.shared
    
    var body: some View {
        ZStack {
            switch coordinator.currentAppState {
            case .launcher:
                LauncherView()
                    .transition(.opacity)
                
            case .inApp(let channel):
                WebContainerView(channel: channel)
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentAppState)
        // 键盘按键备用监听 (方便没有手柄时的开发调试)
        .background(KeyboardEventReceiverView())
    }
}

// ==================== 键盘备用调试捕获 ====================

struct KeyboardEventReceiverView: NSViewRepresentable {
    func makeNSView(context: Context) -> KeyView {
        let view = KeyView()
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }
    
    func updateNSView(_ nsView: KeyView, context: Context) {}
    
    final class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        
        override func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 123: // Left
                FocusCoordinator.shared.handleAction(.left)
            case 124: // Right
                FocusCoordinator.shared.handleAction(.right)
            case 126: // Up
                FocusCoordinator.shared.handleAction(.up)
            case 125: // Down
                FocusCoordinator.shared.handleAction(.down)
            case 36:  // Return / Enter (Xbox A)
                FocusCoordinator.shared.handleAction(.confirm)
            case 53:  // Esc (Xbox B)
                FocusCoordinator.shared.handleAction(.back)
            case 4:   // H (Xbox Y - HUD)
                FocusCoordinator.shared.handleAction(.actionY)
            case 3:   // F (Xbox X - Fullscreen)
                FocusCoordinator.shared.handleAction(.actionX)
            default:
                super.keyDown(with: event)
            }
        }
    }
}
