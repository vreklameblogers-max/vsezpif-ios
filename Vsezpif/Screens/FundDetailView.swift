import SwiftUI
import Charts

struct FundDetailView: View {
    let fund: Fund
    @Environment(AppState.self) private var state
    @State private var addedToPortfolio = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                priceHeader
                chartCard
                metricsGrid
                aboutCard
                addButton
                DemoDataFootnote()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Theme.bgGradient)
        .scrollIndicators(.hidden)
        .navigationTitle(fund.ticker)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.bg.opacity(0.85), for: .navigationBar)
    }

    private var priceHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(fund.segment.rawValue, systemImage: fund.segment.icon)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.blue)
                Spacer()
                Text(fund.isin)
                    .font(.caption2.monospaced())
                    .foregroundStyle(Theme.muted)
            }
            Text(fund.fullName)
                .font(.footnote)
                .foregroundStyle(Theme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(Fmt.rub(fund.price))
                    .font(.system(size: 34, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(Theme.text)
                ChangeBadge(value: fund.analytics.change30d)
                Spacer()
            }
        }
        .glassCard()
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Цена пая · 90 дней")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                Spacer()
            }
            Chart(Array(fund.analytics.priceSeries.enumerated()), id: \.offset) { item in
                LineMark(x: .value("День", item.offset), y: .value("Цена", item.element))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Theme.goldGradient)
                    .lineStyle(StrokeStyle(lineWidth: 2.2, lineCap: .round))
                AreaMark(x: .value("День", item.offset),
                         yStart: .value("min", fund.analytics.priceSeries.min() ?? 0),
                         yEnd: .value("Цена", item.element))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(colors: [Theme.gold.opacity(0.25), .clear],
                                       startPoint: .top, endPoint: .bottom)
                    )
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .trailing) { _ in
                    AxisGridLine().foregroundStyle(Theme.line)
                    AxisValueLabel().foregroundStyle(Theme.muted).font(.caption2)
                }
            }
            .frame(height: 190)
        }
        .glassCard()
    }

    private var metricsGrid: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "Показатели")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                StatTile(title: "Доходность YTD",
                         value: Fmt.pct(fund.analytics.yieldYTD, signed: false),
                         tint: Theme.green)
                StatTile(title: "Дивидендная доходность",
                         value: Fmt.pct(fund.analytics.dividendYield, signed: false),
                         tint: Theme.gold)
                StatTile(title: "СЧА",
                         value: String(format: "%.1f млрд ₽", fund.analytics.nav)
                             .replacingOccurrences(of: ".", with: ","))
                StatTile(title: "Комиссия УК",
                         value: Fmt.pct(fund.analytics.feeUK, signed: false))
                StatTile(title: "Заполняемость",
                         value: Fmt.pct(fund.analytics.occupancy, signed: false),
                         tint: Theme.blue)
                StatTile(title: "Объём торгов",
                         value: fund.volumeRub.map { Fmt.rub($0) } ?? "—")
            }
        }
        .glassCard()
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "О фонде")
            row("Тикер", fund.ticker)
            row("ISIN", fund.isin)
            row("Сегмент", fund.segment.rawValue)
            row("Раскрытие", "MOEX + сайт УК")
        }
        .glassCard()
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.footnote).foregroundStyle(Theme.muted)
            Spacer()
            Text(value).font(.footnote.weight(.medium)).foregroundStyle(Theme.text)
        }
        .padding(.vertical, 2)
    }

    private var addButton: some View {
        Button {
            Haptics.success()
            withAnimation(.snappy) {
                if let i = state.portfolio.firstIndex(where: { $0.fund.id == fund.id }) {
                    state.portfolio[i].quantity += 10
                } else {
                    state.portfolio.append(Position(fund: fund, quantity: 10))
                }
                addedToPortfolio = true
            }
        } label: {
            Label(addedToPortfolio ? "Добавлено в портфель" : "Добавить в портфель",
                  systemImage: addedToPortfolio ? "checkmark.circle.fill" : "plus.circle.fill")
                .font(.headline)
                .foregroundStyle(addedToPortfolio ? Theme.green : Theme.bg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                        .fill(addedToPortfolio ? AnyShapeStyle(Theme.green.opacity(0.15))
                                               : AnyShapeStyle(Theme.goldGradient))
                )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: addedToPortfolio)
    }
}
