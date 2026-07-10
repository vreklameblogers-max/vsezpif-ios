import SwiftUI

@Observable
final class AppState {
    private let repository: any FundsProviding

    var funds: [Fund] = []
    var updatedAt: String = ""
    var isLoading = true

    var portfolio: [Position] = []
    var alerts: [PriceAlert] = []
    var indices: [MarketIndex] = []

    init(repository: any FundsProviding = MockRepository()) {
        self.repository = repository
    }

    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await repository.loadFunds()
            funds = result.funds
            updatedAt = result.updatedAt
            buildDemoState()
        } catch {
            funds = []
        }
    }

    // Демо-портфель и демо-алерты поверх реальных фондов (в проде — из API).
    private func buildDemoState() {
        guard funds.count >= 3 else { return }
        if portfolio.isEmpty {
            portfolio = [
                Position(fund: funds[0], quantity: 120),
                Position(fund: funds[1], quantity: 45),
                Position(fund: funds[2], quantity: 200),
            ]
        }
        if alerts.isEmpty {
            alerts = [
                PriceAlert(fund: funds[0], condition: .above, threshold: (funds[0].price * 1.03).rounded()),
                PriceAlert(fund: funds[1], condition: .below, threshold: (funds[1].price * 0.95).rounded()),
                PriceAlert(fund: funds[2], condition: .above, threshold: (funds[2].price * 1.05).rounded(), isOn: false),
            ]
        }
        if indices.isEmpty {
            indices = Self.demoIndices(from: funds)
        }
    }

    // Индексы VZPIF — демо-расчёт из цен фондов (в проде — таблицы index_values).
    private static func demoIndices(from funds: [Fund]) -> [MarketIndex] {
        func series(_ seed: String, base: Double) -> [Double] {
            var rng = SeededRandom(string: seed)
            var v = base * 0.94
            return (0..<60).map { _ in
                v += v * rng.range(-0.006...0.009)
                return v
            }
        }
        let all = funds.map(\.price).reduce(0, +) / Double(max(funds.count, 1))
        let s1 = series("VZPIF-TOTAL", base: all)
        let s2 = series("VZPIF-RENT", base: all * 0.82)
        let s3 = series("VZPIF-GROWTH", base: all * 1.13)
        func chg(_ s: [Double]) -> Double { (s.last! / s[s.count - 22] - 1) * 100 }
        return [
            MarketIndex(id: "VZPIF",   name: "VZPIF Композитный", value: s1.last!, changePct: chg(s1), series: s1),
            MarketIndex(id: "VZPIF-R", name: "VZPIF Рентный",     value: s2.last!, changePct: chg(s2), series: s2),
            MarketIndex(id: "VZPIF-G", name: "VZPIF Рост",        value: s3.last!, changePct: chg(s3), series: s3),
        ]
    }

    // MARK: - Портфель: агрегаты

    var portfolioValue: Double { portfolio.reduce(0) { $0 + $1.value } }

    var portfolioYield: Double {
        guard portfolioValue > 0 else { return 0 }
        return portfolio.reduce(0) { $0 + $1.fund.analytics.dividendYield * $1.value } / portfolioValue
    }
}
