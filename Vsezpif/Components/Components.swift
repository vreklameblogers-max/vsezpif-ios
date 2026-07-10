import SwiftUI
import Charts

// MARK: - Заголовок секции

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Theme.text)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Бейдж изменения цены

struct ChangeBadge: View {
    let value: Double

    var body: some View {
        Text(Fmt.pct(value))
            .font(.caption.weight(.semibold).monospacedDigit())
            .foregroundStyle(value >= 0 ? Theme.green : Theme.red)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill((value >= 0 ? Theme.green : Theme.red).opacity(0.12))
            )
    }
}

// MARK: - Спарклайн

struct Sparkline: View {
    let series: [Double]
    var tint: Color = Theme.gold

    var body: some View {
        Chart(Array(series.enumerated()), id: \.offset) { item in
            LineMark(x: .value("t", item.offset), y: .value("v", item.element))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(tint)
                .lineStyle(StrokeStyle(lineWidth: 1.8, lineCap: .round))
            AreaMark(x: .value("t", item.offset),
                     yStart: .value("min", series.min() ?? 0),
                     yEnd: .value("v", item.element))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(colors: [tint.opacity(0.22), .clear],
                                   startPoint: .top, endPoint: .bottom)
                )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: (series.min() ?? 0)...(series.max() ?? 1))
    }
}

// MARK: - Карточка фонда в каталоге

struct FundCard: View {
    let fund: Fund

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.cardHover)
                    .frame(width: 46, height: 46)
                Image(systemName: fund.segment.icon)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(Theme.gold)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(fund.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("\(fund.ticker) · \(fund.segment.rawValue)")
                    .font(.caption2)
                    .foregroundStyle(Theme.muted)
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            Sparkline(series: fund.analytics.lastMonthSeries,
                      tint: fund.analytics.change30d >= 0 ? Theme.green : Theme.red)
                .frame(width: 52, height: 28)

            VStack(alignment: .trailing, spacing: 3) {
                Text(Fmt.rub(fund.price))
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(Theme.text)
                ChangeBadge(value: fund.analytics.change30d)
            }
            .fixedSize()
        }
        .glassCard(padding: 14)
    }
}

// MARK: - Плитка метрики

struct StatTile: View {
    let title: String
    let value: String
    var tint: Color = Theme.text

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(Theme.muted)
            Text(value)
                .font(.callout.weight(.bold).monospacedDigit())
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.cardHover.opacity(0.6))
        )
    }
}

// MARK: - Skeleton

struct SkeletonRow: View {
    @State private var shine = false

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12).frame(width: 46, height: 46)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4).frame(width: 140, height: 12)
                RoundedRectangle(cornerRadius: 4).frame(width: 90, height: 9)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 8).frame(width: 70, height: 26)
        }
        .foregroundStyle(Theme.cardHover.opacity(shine ? 0.9 : 0.45))
        .glassCard(padding: 14)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { shine = true }
        }
    }
}

// MARK: - Пометка демо-данных (принцип честности из CLAUDE.md веб-проекта)

struct DemoDataFootnote: View {
    var body: some View {
        Label("Котировки — снимок MOEX. Аналитика — демонстрационная.",
              systemImage: "info.circle")
            .font(.caption2)
            .foregroundStyle(Theme.muted)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 6)
    }
}
