import SwiftUI
import UIKit

// Дизайн-токены перенесены 1:1 из CSS веб-версии (app/index.html :root)
// — единственный источник истины для палитры (ADR-016).
enum Theme {
    static let bg        = Color(hex: 0x080D1A)   // --bg
    static let card      = Color(hex: 0x0F1930)   // --card
    static let cardHover = Color(hex: 0x142440)   // --card-hover
    static let text      = Color(hex: 0xEAF0FB)   // --text
    static let muted     = Color(hex: 0x66738F)   // --muted
    static let gold      = Color(hex: 0xD9B36A)   // --gold
    static let green     = Color(hex: 0x3DD68C)   // --green
    static let red       = Color(hex: 0xF2647C)   // --red
    static let blue      = Color(hex: 0x5B8DEF)   // --blue

    static let line       = Color(hex: 0x94B2FF).opacity(0.10)  // --line
    static let lineStrong = Color(hex: 0x94B2FF).opacity(0.18)  // --line-strong

    static let corner: CGFloat = 16               // --radius

    // --gold-grad
    static let goldGradient = LinearGradient(
        colors: [Color(hex: 0xC9A050), Color(hex: 0xEFD79C), Color(hex: 0xC9A050)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let bgGradient = LinearGradient(
        colors: [Color(hex: 0x080D1A), Color(hex: 0x0B1224), Color(hex: 0x080D1A)],
        startPoint: .top, endPoint: .bottom
    )
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255
        )
    }
}

// Стеклянная карточка — базовая поверхность всего приложения.
struct GlassCard: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    .fill(Theme.card.opacity(0.82))
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    .strokeBorder(Theme.line, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 18, y: 8)
    }
}

extension View {
    func glassCard(padding: CGFloat = 16) -> some View {
        modifier(GlassCard(padding: padding))
    }
}

enum Haptics {
    static func tap()     { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func select()  { UISelectionFeedbackGenerator().selectionChanged() }
}

// Форматирование чисел в стиле сайта: 1 306 ₽, +4,2 %
enum Fmt {
    static func rub(_ value: Double, fraction: Int = 0) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "\u{202F}"
        f.maximumFractionDigits = fraction
        let s = f.string(from: value as NSNumber) ?? "\(Int(value))"
        return "\(s) ₽"
    }

    static func pct(_ value: Double, signed: Bool = true) -> String {
        let sign = signed && value > 0 ? "+" : ""
        return String(format: "%@%.1f", sign, value).replacingOccurrences(of: ".", with: ",") + " %"
    }
}
