import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var state
    @State private var search = ""
    @State private var segment: Segment? = nil

    private var filtered: [Fund] {
        state.funds.filter { fund in
            (segment == nil || fund.segment == segment) &&
            (search.isEmpty
             || fund.name.localizedCaseInsensitiveContains(search)
             || fund.ticker.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    marketHeader

                    segmentChips

                    if state.isLoading {
                        ForEach(0..<6, id: \.self) { _ in SkeletonRow() }
                    } else {
                        ForEach(filtered) { fund in
                            NavigationLink(value: fund) {
                                FundCard(fund: fund)
                            }
                            .buttonStyle(.plain)
                        }
                        if filtered.isEmpty {
                            ContentUnavailableView.search(text: search)
                                .foregroundStyle(Theme.muted)
                        }
                        DemoDataFootnote()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Theme.bgGradient)
            .scrollIndicators(.hidden)
            .refreshable {
                Haptics.tap()
                await state.load()
            }
            .searchable(text: $search, prompt: "Фонд или тикер")
            .navigationTitle("Фонды")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Fund.self) { FundDetailView(fund: $0) }
            .toolbarBackground(Theme.bg.opacity(0.85), for: .navigationBar)
        }
    }

    // Сводка рынка над списком
    private var marketHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Фондов в базе")
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
                Text("\(state.funds.count)")
                    .font(.system(.title, design: .rounded, weight: .heavy).monospacedDigit())
                    .foregroundStyle(Theme.goldGradient)
            }
            Spacer()
            if let idx = state.indices.first {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(idx.name)
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                    HStack(spacing: 8) {
                        Sparkline(series: Array(idx.series.suffix(20)),
                                  tint: idx.changePct >= 0 ? Theme.green : Theme.red)
                            .frame(width: 56, height: 22)
                        ChangeBadge(value: idx.changePct)
                    }
                }
            }
        }
        .glassCard()
    }

    private var segmentChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "Все", isOn: segment == nil) { segment = nil }
                ForEach(Segment.allCases) { s in
                    chip(title: s.rawValue, isOn: segment == s) {
                        segment = segment == s ? nil : s
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func chip(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.select()
            withAnimation(.snappy) { action() }
        } label: {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(isOn ? Theme.bg : Theme.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isOn ? AnyShapeStyle(Theme.goldGradient)
                                        : AnyShapeStyle(Theme.card))
                )
                .overlay(Capsule().strokeBorder(Theme.line, lineWidth: isOn ? 0 : 1))
        }
        .buttonStyle(.plain)
    }
}
