import Foundation

final class TemperatureSampler {
    private let provider: TemperatureStatsProviding

    init(provider: TemperatureStatsProviding = SMCTemperatureProvider()) {
        self.provider = provider
    }

    func refresh() throws -> TemperatureUsage {
        try provider.currentStats()
    }
}
