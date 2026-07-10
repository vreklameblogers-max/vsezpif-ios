import SwiftUI

struct OnboardingView: View {
    let finish: () -> Void
    @State private var page = 0

    private let pages: [(icon: String, title: String, text: String)] = [
        ("building.columns.fill", "Все ЗПИФ недвижимости",
         "Полный каталог фондов с котировками Московской биржи и данными раскрытия УК."),
        ("chart.line.uptrend.xyaxis", "Собственные индексы",
         "Семейство индексов VZPIF показывает состояние рынка одним взглядом."),
        ("bell.badge.fill", "Сигналы и алерты",
         "Уведомления о движении цены, выплатах и новых раскрытиях — раньше всех."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { i in
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Theme.gold.opacity(0.12))
                                .frame(width: 168, height: 168)
                            Image(systemName: pages[i].icon)
                                .font(.system(size: 64, weight: .medium))
                                .foregroundStyle(Theme.goldGradient)
                        }
                        VStack(spacing: 12) {
                            Text(pages[i].title)
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text(pages[i].text)
                                .font(.callout)
                                .foregroundStyle(Theme.muted)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }
                        .padding(.horizontal, 36)
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                Haptics.tap()
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    finish()
                }
            } label: {
                Text(page < pages.count - 1 ? "Далее" : "Начать")
                    .font(.headline)
                    .foregroundStyle(Theme.bg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.goldGradient, in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            Button("Пропустить") { finish() }
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
                .padding(.bottom, 20)
        }
    }
}
