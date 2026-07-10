import SwiftUI

struct SplashView: View {
    @State private var appear = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Theme.goldGradient)
                    .frame(width: 96, height: 96)
                    .shadow(color: Theme.gold.opacity(0.45), radius: 30, y: 10)
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(Theme.bg)
            }
            .scaleEffect(appear ? 1 : 0.7)
            .opacity(appear ? 1 : 0)

            VStack(spacing: 6) {
                Text("ВСЁ О ЗПИФ")
                    .font(.system(.title, design: .rounded, weight: .heavy))
                    .foregroundStyle(Theme.text)
                    .kerning(2)
                Text("Аналитика фондов недвижимости")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 12)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { appear = true }
        }
    }
}
