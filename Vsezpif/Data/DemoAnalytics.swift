import Foundation

// ДЕМОНСТРАЦИОННАЯ аналитика (ADR-016).
// Реальны в приложении: имена фондов, тикеры, ISIN и последняя цена — снимок MOEX ISS из funds.json.
// Всё производное (история цены, доходность, СЧА, комиссия) генерируется детерминированно
// из ISIN, чтобы выглядеть правдоподобно и не меняться между запусками.
// При появлении Data API этот файл заменяется реальными полями ответа.

struct DemoAnalytics: Hashable {
    let yieldYTD: Double        // доходность с начала года, %
    let change30d: Double       // изменение цены за 30 дней, %
    let dividendYield: Double   // дивидендная доходность, % годовых
    let feeUK: Double           // комиссия УК, %
    let nav: Double             // СЧА, млрд ₽
    let occupancy: Double       // заполняемость объектов, %
    let priceSeries: [Double]   // 90 точек истории цены (заканчивается реальной ценой)

    var lastMonthSeries: [Double] { Array(priceSeries.suffix(30)) }

    init(seedString: String, basePrice: Double) {
        var rng = SeededRandom(string: seedString)

        yieldYTD      = rng.range(4.0...16.5)
        change30d     = rng.range(-3.5...6.0)
        dividendYield = rng.range(8.0...13.5)
        feeUK         = (rng.range(0.8...2.2) * 10).rounded() / 10
        nav           = (rng.range(1.2...28.0) * 10).rounded() / 10
        occupancy     = rng.range(88.0...100.0)

        // Случайное блуждание назад от реальной цены — график всегда приходит в неё.
        let start = basePrice / (1 + change30d / 100 * 3)
        var series: [Double] = []
        var value = start
        let drift = (basePrice - start) / 89
        for _ in 0..<89 {
            value += drift + value * rng.range(-0.011...0.011)
            series.append(max(value, basePrice * 0.55))
        }
        series.append(basePrice)
        priceSeries = series
    }
}

// xorshift64* — простой детерминированный генератор; сид — из строки ISIN.
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64

    init(string: String) {
        var h: UInt64 = 0xcbf29ce484222325
        for b in string.utf8 {
            h ^= UInt64(b)
            h = h &* 0x100000001b3
        }
        state = h == 0 ? 0x9E3779B97F4A7C15 : h
    }

    mutating func next() -> UInt64 {
        state ^= state >> 12
        state ^= state << 25
        state ^= state >> 27
        return state &* 2685821657736338717
    }

    mutating func range(_ r: ClosedRange<Double>) -> Double {
        Double.random(in: r, using: &self)
    }
}
