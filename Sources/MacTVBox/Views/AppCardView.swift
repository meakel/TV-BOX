import SwiftUI

// ==================== Apple TV 风格 3D 聚焦卡片 ====================

public struct AppCardView: View {
    public let item: LauncherItem
    public let isFocused: Bool
    
    public init(item: LauncherItem, isFocused: Bool) {
        self.item = item
        self.isFocused = isFocused
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // 图标主体视差卡片
            ZStack {
                // 渐变底板
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [item.brandColor, item.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // 图标展示：优先原生 App 高清图标，次选矢量 Symbol
                if let customIcon = item.customIcon {
                    Image(nsImage: customIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 84, height: 84)
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                } else if let symbol = item.symbolIcon {
                    Image(systemName: symbol)
                        .font(.system(size: 54, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                
                // 右上角角标（TV 或 本地）
                if let badge = item.badgeText {
                    VStack {
                        HStack {
                            Spacer()
                            Text(badge)
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.4))
                                )
                                .padding(10)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 140)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isFocused ? Color.white : Color.clear, lineWidth: 3.5)
            )
            .shadow(
                color: isFocused ? item.brandColor.opacity(0.85) : Color.black.opacity(0.35),
                radius: isFocused ? 24 : 8,
                x: 0,
                y: isFocused ? 12 : 4
            )
            
            // 下方文字标签
            Text(item.title)
                .font(.system(size: 16, weight: isFocused ? .bold : .medium))
                .foregroundColor(isFocused ? .white : .white.opacity(0.65))
                .lineLimit(1)
        }
        .scaleEffect(isFocused ? 1.10 : 0.96)
        .opacity(isFocused ? 1.0 : 0.72)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isFocused)
    }
}
