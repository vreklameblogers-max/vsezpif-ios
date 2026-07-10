import SwiftUI

struct ConstructorView: View {
    @Environment(AppState.self) private var state
    @State private var amount: Double = 300_000
    @State private var picked: Set<String> = []

    private var chosen: [Fund] { state.funds.filter { picked.contains($0.id) } }

    private var expectedYield: Double {
        guard !chosen.isEmpty else { return 0 }
        return chosen.map(\.analytics.dividendYield).reduce(0, +) / Double(chosen.count)
    }

    private var monthlyIncome: Double { amount * expectedYield / 100 / 12 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    amountCard
                    resultCard
                    SectionHeader(title: "Выберите фонды",
                                  subtitle: "Портфель распределится поровну")
                        .padding(.horizontal, 2)
                    ForEach(state.funds) { fund in
                        pickRow(fund)
                    }
                    DemoDataFootnote()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Theme.bgGradient)
            .scrollIndicators(.hidden)
            .navigationTitle("Конструктор")
            .toolbarBackground(Theme.bg.opacity(0.85), for: .navigationBar)
        }
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сумма инвестиций")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.muted)
            Text(Fmt.rub(amount))
                .font(.system(size: 30, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(Theme.goldGradient)
                .contentTransition(.numericText())
            Slider(value: $amount, in: 50_000...5_000_000, step: 50_000)
                .tint(Theme.gold)
                .onChange(of: amount) { Haptics.select() }
        }
        .glassCard()
    }

    private var resultCard: some View {
        HStack(spacing: 10) {
            StatTile(title: "Ожидаемая доходность",
                     value: chosen.isEmpty ? "—" : Fmt.pct(expectedYield, signed: false),
                     tint: Theme.green)
            StatTile(title: "Доход в месяц",
                     value: chosen.isEmpty ? "—" : Fmt.rub(monthlyIncome),
                     tint: Theme.gold)
            StatTile(title: "Фондов",
                     value: "\(chosen.count)")
        }
        .glassCard(padding: 12)
        .animation(.snappy, value: picked)
    }

    private func pickRow(_ fund: Fund) -> some View {
        Button {
            Haptics.select()
            withAnimation(.snappy) {
                if picked.contains(fund.id) { picked.remove(fund.id) }
                else { picked.insert(fund.id) }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: picked.contains(fund.id) ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(picked.contains(fund.id) ? Theme.gold : Theme.muted)
                VStack(alignment: .leading, spacing: 2) {
                    Text(fund.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.text)
                    Text("\(fund.segment.rawValue) · див. \(Fmt.pct(fund.analytics.dividendYield, signed: false))")
                        .font(.caption2)
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Text(Fmt.rub(fund.price))
                    .font(.footnote.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Theme.text)
            }
            .glassCard(padding: 14)
        }
        .buttonStyle(.plain)
    }
}
