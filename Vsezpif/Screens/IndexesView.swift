import SwiftUI
import Charts

struct IndexesView: View {
    @Environment(AppState.self) private var state
    @State private var selected: MarketIndex? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    if let idx = selected ?? state.indices.first {
                        bigChart(idx)
                    }
                    ForEach(state.indices) { idx in
                        Button {
                            Haptics.select()
                            withAnimation(.snappy) { selected = idx }
                        } label: {
                            indexRow(idx)
                        }
                        .buttonStyle(.plain)
                    }
                    DemoDataFootnote()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Theme.bgGradient)
            .scrollIndicators(.hidden)
            .navigationTitle("Индексы VZPIF")
            .toolbarBackground(Theme.bg.opacity(0.85), for: .navigationBar)
        }
    }

    private func bigChart(_ idx: MarketIndex) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(idx.name)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                    Text(String(format: "%.1f", idx.value).replacingOccurrences(of: ".", with: ","))
                        .font(.system(size: 30, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(Theme.text)
                }
                Spacer()
                ChangeBadge(value: idx.changePct)
            }
            Chart(Array(idx.series.enumerated()), id: \.offset) { item in
                LineMark(x: .value("t", item.offset), y: .value("v", item.element))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(idx.changePct >= 0 ? Theme.green : Theme.red)
                    .lineStyle(StrokeStyle(lineWidth: 2.2, lineCap: .round))
                AreaMark(x: .value("t", item.offset),
                         yStart: .value("min", idx.series.min() ?? 0),
                         yEnd: .value("v", item.element))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(colors: [(idx.changePct >= 0 ? Theme.green : Theme.red).opacity(0.2), .clear],
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
            .frame(height: 200)
        }
        .glassCard()
    }

    private func indexRow(_ idx: MarketIndex) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(idx.id)
                    .font(.caption.monospaced())
                    .foregroundStyle(Theme.gold)
                Text(idx.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.text)
            }
            Spacer()
            Sparkline(series: Array(idx.series.suffix(24)),
                      tint: idx.changePct >= 0 ? Theme.green : Theme.red)
                .frame(width: 70, height: 26)
            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.1f", idx.value).replacingOccurrences(of: ".", with: ","))
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(Theme.text)
                ChangeBadge(value: idx.changePct)
            }
        }
        .glassCard(padding: 14)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                .strokeBorder((selected?.id == idx.id) ? Theme.gold.opacity(0.5) : .clear, lineWidth: 1.5)
        )
    }
}
