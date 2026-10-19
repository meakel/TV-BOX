import SwiftUI

// ==================== Apple TV Top Shelf 沉浸式顶部展架 ====================

public struct TopShelfView: View {
    public let item: LauncherItem?
    
    public init(item: LauncherItem?) {
        self.item = item
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景沉浸式氛围渐变
            if let item = item {
                LinearGradient(
                    gradient: Gradient(colors: [
                        item.brandColor.opacity(0.45),
                        item.secondaryColor.opacity(0.2),
                        Color.black.opacity(0.85)
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: item.id)
            } else {
                Color.black.opacity(0.6)
            }
            
            // 底部黑色羽化渐变蒙层，与下方应用网格无缝衔接
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color(red: 0.05, green: 0.05, blue: 0.07).opacity(0.8),
                    Color(red: 0.05, green: 0.05, blue: 0.07)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // 焦点项的详细海报信息
            if let item = item {
                HStack(alignment: .bottom, spacing: 28) {
                    // 大图标展示
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [item.brandColor, item.secondaryColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 110, height: 110)
                            .shadow(color: item.brandColor.opacity(0.6), radius: 20, x: 0, y: 10)
                        
                        if let customIcon = item.customIcon {
                            Image(nsImage: customIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 76, height: 76)
                        } else if let symbol = item.symbolIcon {
                            Image(systemName: symbol)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Text(item.title)
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 3)
                            
                            if let badge = item.badgeText {
                                Text(badge)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(item.brandColor.opacity(0.8)))
                            }
                        }
                        
                        Text(item.subtitle)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                            .frame(maxWidth: 600, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            labelTag(icon: "gamecontroller.fill", text: "Xbox 控制器完全适配")
                            labelTag(icon: "tv.fill", text: "4K 沉浸视听")
                            labelTag(icon: "bolt.fill", text: "秒开启动")
                        }
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 64)
                .padding(.bottom, 24)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .frame(height: 280)
    }
    
    private func labelTag(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(.white.opacity(0.65))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.white.opacity(0.12)))
    }
}
