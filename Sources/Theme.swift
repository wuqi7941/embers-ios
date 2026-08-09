import SwiftUI

enum Ember {
    // MARK: - 余烬色板：炭黑夜里烧红的那一点光

    static let coal        = Color(red: 0.043, green: 0.043, blue: 0.055)   // 背景炭黑
    static let panel       = Color(red: 0.082, green: 0.082, blue: 0.102)   // 卡片面板
    static let panelHi     = Color(red: 0.110, green: 0.110, blue: 0.133)   // 按压高亮
    static let ember       = Color(red: 0.941, green: 0.400, blue: 0.227)   // 主橙：烧红的炭
    static let emberGold   = Color(red: 0.961, green: 0.651, blue: 0.357)   // 亮焰
    static let emberDeep   = Color(red: 0.851, green: 0.282, blue: 0.173)   // 深焰
    static let paper       = Color(red: 0.929, green: 0.906, blue: 0.866)   // 主文：暖纸白
    static let ash         = Color(red: 0.604, green: 0.573, blue: 0.525)   // 灰烬：次级文字
    static let hairline    = Color.white.opacity(0.08)                      // 分隔线

    // MARK: - 渐变

    static let emberGradient = LinearGradient(
        colors: [emberGold, ember, emberDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let coalGradient = LinearGradient(
        colors: [
            Color(red: 0.055, green: 0.051, blue: 0.067),
            coal,
            Color(red: 0.035, green: 0.043, blue: 0.055),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - 排版

    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }

    static func serif(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif).italic()
    }
}

// MARK: - 余烬点缀：一行渐隐的烛火竖线

struct EmberTick: View {
    var height: CGFloat = 36

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Ember.emberGradient)
            .frame(width: 3, height: height)
            .shadow(color: Ember.ember.opacity(0.55), radius: 6, x: 0, y: 0)
    }
}