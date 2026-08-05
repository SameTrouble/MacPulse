import Foundation

protocol CPUTickProviding {
    func currentTicks() throws -> [CPUTick]
}

final class CPUUsageSampler: Sampling {
    private let provider: CPUTickProviding
    private var previous: [CPUTick]?

    init(provider: CPUTickProviding = HostProcessorInfoProvider()) {
        self.provider = provider
    }

    func refresh() throws -> CPUUsage? {
        let current = try provider.currentTicks()
        defer { previous = current }
        guard let previous else { return nil }
        return CPUUsageCalculator.usage(previous: previous, current: current)
    }
}
