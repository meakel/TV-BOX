import SwiftUI

// ==================== Xbox 手柄操作提示悬浮窗 ====================

public struct OverlayHUDView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 24))
                Text("Xbox 手柄操控指南")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundColor(.white)
            
            Divider().background(Color.white.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 14) {
                hudRow(key: "A 键 (绿色)", desc: "确认打开选中的应用 / 视频播放与暂停")
                hudRow(key: "B 键 (红色)", desc: "退出播放器回到 Apple TV 主屏")
                hudRow(key: "X 键 (蓝色)", desc: "主屏切换分类 / 播放页全屏 / 抖音点赞")
                hudRow(key: "Y 键 (黄色)", desc: "打开或关闭本手柄操作指南")
                hudRow(key: "十字键 / 摇杆", desc: "主屏 2D 网格上下左右移动 / 视频进度 / 抖音刷视频")
                hudRow(key: "LB / RB", desc: "上一集 / 下一集 / 快速切视频")
                hudRow(key: "LT / RT", desc: "快退 10 秒 / 快进 10 秒")
            }
        }
        .padding(32)
        .frame(width: 520)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.6), radius: 30, x: 0, y: 15)
        )
    }
    
    private func hudRow(key: String, desc: String) -> some View {
        HStack {
            Text(key)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.yellow)
                .frame(width: 160, alignment: .leading)
            
            Text(desc)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}
