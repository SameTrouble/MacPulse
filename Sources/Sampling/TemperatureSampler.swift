import Foundation

final class TemperatureSampler {
    private let provider: TemperatureStatsProviding
    private let coalesceInterval: TimeInterval
    private var cachedResult: Result<TemperatureUsage, Error>?
    private var cachedAt: Date?

    init(
        provider: TemperatureStatsProviding = SMCTemperatureProvider(),
        coalesceInterval: TimeInterval = 0.1
    ) {
        self.provider = provider
        self.coalesceInterval = coalesceInterval
    }

    func refresh() throws -> TemperatureUsage {
        if let cachedAt,
           let cachedResult,
           Date().timeIntervalSince(cachedAt) < coalesceInterval {
            return try cachedResult.get()
        }
        let result = Result { try provider.currentStats() }
        cachedResult = result
        cachedAt = Date()
        return try result.get()
    }
}
