import Foundation

// Единственная точка получения данных.
// Сейчас — MockRepository (локальный funds.json).
// При появлении Data API добавляется ApiRepository: FundsProviding
// с теми же сигнатурами — экраны не меняются (ADR-016).
protocol FundsProviding: Sendable {
    func loadFunds() async throws -> (funds: [Fund], updatedAt: String)
}

struct MockRepository: FundsProviding {
    func loadFunds() async throws -> (funds: [Fund], updatedAt: String) {
        // Небольшая задержка — чтобы skeleton-состояния были видны, как при реальной сети.
        try? await Task.sleep(for: .milliseconds(650))

        guard let url = Bundle.main.url(forResource: "funds", withExtension: "json") else {
            throw RepositoryError.missingMock
        }
        let data = try Data(contentsOf: url)
        let file = try JSONDecoder().decode(FundsFile.self, from: data)
        let funds = file.funds
            .map(Fund.init(dto:))
            .filter { $0.price > 0 }
            .sorted { $0.analytics.nav > $1.analytics.nav }
        return (funds, file.updated_at)
    }
}

enum RepositoryError: Error {
    case missingMock
}
