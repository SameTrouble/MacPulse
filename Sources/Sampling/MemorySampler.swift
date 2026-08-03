import Foundation

protocol MemoryStatsProviding {
    func currentStats() throws -> MemoryStats
}

final class MemorySampler {
    private let provider: MemoryStatsProviding

    init(provider: MemoryStatsProviding = HostMemoryInfoProvider()) {
        self.provider = provider
    }

    func refresh() throws -> MemoryUsage {
        MemoryUsageCalculator.usage(try provider.currentStats())
    }
}
