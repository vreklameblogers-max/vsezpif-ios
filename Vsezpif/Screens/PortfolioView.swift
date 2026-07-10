import SwiftUI
import Charts

struct PortfolioView: View {
    @Environment(AppState.self) private var state
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    totalCard
                    allocationCard
                    SectionHeader(title: "Позиции")
                        .padding(.horizontal, 2)
                    ForEach(state.portfolio) { position in
                        positionRow(position)
                    }
                    payoutsCard
                    DemoDataFootnote()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Theme.bgGradient)
            .scrollIndicators(.hidden)
            .navigationTitle("Кабинет")
            .toolbarBackground(Theme.bg.opacity(0.85), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.tap()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Theme.muted)
                    }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    private var totalCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Стоимость портфеля")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.muted)
            Text(Fmt.rub(state.portfolioValue))
                .font(.system(size: 34, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(Theme.goldGradient)
                .contentTransition(.numericText())
            HStack(spacing: 10) {
                StatTile(title: "Дивидендная доходность",
                         value: Fmt.pct(state.portfolioYield, signed: false),
                         tint: Theme.green)
                StatTile(title: "Доход в месяц",
                         value: Fmt.rub(state.portfolioValue * state.portfolioYield / 100 / 12),
                         tint: Theme.gold)
            }
        }
        .glassCard()
    }

    private var allocationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Распределение")
            Chart(state.portfolio) { position in
                SectorMark(
                    angle: .value("Доля", position.value),
                    innerRadius: .ratio(0.65),
                    angularInset: 2
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Фонд", position.fund.ticker))
            }
            .chartForegroundStyleScale(range: [Theme.gold, Theme.blue, Theme.green, Theme.red])
            .chartLegend(position: .bottom, spacing: 12)
            .frame(height: 200)
        }
        .glassCard()
    }

    private func positionRow(_ position: Position) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.cardHover)
                    .frame(width: 40, height: 40)
                Image(systemName: position.fund.segment.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.gold)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(position.fund.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.text)
                Text("\(position.quantity) паёв · \(Fmt.rub(position.fund.price))")
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(Fmt.rub(position.value))
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(Theme.text)
                ChangeBadge(value: position.fund.analytics.change30d)
            }
        }
        .glassCard(padding: 14)
    }

    private var payoutsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Ближайшие выплаты", subtitle: "Календарь дивидендов")
            ForEach(Array(state.portfolio.prefix(3).enumerated()), id: \.offset) { i, position in
                HStack(spacing: 12) {
                    VStack(spacing: 1) {
                        Text("\(12 + i * 9)")
                            .font(.callout.weight(.bold).monospacedDigit())
                            .foregroundStyle(Theme.text)
                        Text(["июл", "авг", "авг"][i])
                            .font(.caption2)
                            .foregroundStyle(Theme.muted)
                    }
                    .frame(width: 40)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Theme.cardHover.opacity(0.6))
                    )
                    Text(position.fund.name)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                    Spacer()
                    Text(Fmt.rub(position.value * position.fund.analytics.dividendYield / 100 / 12))
                        .font(.footnote.weight(.semibold).monospacedDigit())
                        .foregroundStyle(Theme.green)
                }
            }
        }
        .glassCard()
    }
}
