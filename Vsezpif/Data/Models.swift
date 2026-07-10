import Foundation

// MARK: - DTO: структура Resources/Mock/funds.json (копия app/data/funds.json веб-версии)

struct FundsFile: Decodable {
    let updated_at: String
    let funds_total: Int
    let funds: [FundDTO]
}

struct FundDTO: Decodable {
    let proto: String
    let secid: String?
    let shortname: String?
    let secname: String?
    let isin: String?
    let price: Double?
    let volume_rub: Double?
    let board: String?
    let source: String?
    let uk_site: String?
}

// MARK: - Доменная модель

struct Fund: Identifiable, Hashable {
    let id: String            // proto — стабильный ключ, как в вебе
    let name: String
    let ticker: String
    let fullName: String
    let isin: String
    let price: Double
    let volumeRub: Double?
    let segment: Segment
    let analytics: DemoAnalytics   // производные ДЕМО-метрики (см. DemoAnalytics.swift)

    init(dto: FundDTO) {
        self.id = dto.proto
        self.name = dto.proto
        self.ticker = dto.shortname ?? dto.secid ?? dto.proto
        self.fullName = dto.secname ?? dto.proto
        self.isin = dto.isin ?? dto.secid ?? "—"
        self.price = dto.price ?? 0
        self.volumeRub = dto.volume_rub
        self.segment = Segment(fundName: dto.proto)
        self.analytics = DemoAnalytics(seedString: dto.isin ?? dto.proto, basePrice: dto.price ?? 1000)
    }
}

enum Segment: String, CaseIterable, Identifiable {
    case logistics = "Логистика"
    case offices   = "Офисы"
    case retail    = "Торговля"
    case living    = "Жильё"
    case mixed     = "Смешанный"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .logistics: return "shippingbox.fill"
        case .offices:   return "building.2.fill"
        case .retail:    return "cart.fill"
        case .living:    return "house.fill"
        case .mixed:     return "square.grid.2x2.fill"
        }
    }

    init(fundName: String) {
        let n = fundName.lowercased()
        if n.contains("лог") || n.contains("склад")            { self = .logistics }
        else if n.contains("офис") || n.contains("сити")       { self = .offices }
        else if n.contains("торг") || n.contains("ритейл")     { self = .retail }
        else if n.contains("жил") || n.contains("рентал")      { self = .living }
        else                                                   { self = .mixed }
    }
}

// MARK: - Портфель и алерты (демо-состояние, в проде — PostgreSQL через API)

struct Position: Identifiable {
    let id = UUID()
    let fund: Fund
    var quantity: Int
    var value: Double { Double(quantity) * fund.price }
}

struct PriceAlert: Identifiable {
    enum Condition: String { case above = "выше", below = "ниже" }
    let id = UUID()
    let fund: Fund
    let condition: Condition
    let threshold: Double
    var isOn: Bool = true
}

struct MarketIndex: Identifiable {
    let id: String
    let name: String
    let value: Double
    let changePct: Double
    let series: [Double]
}
