import Foundation

final class GPUSampler {
    private let provider: GPUStatsProviding

    init(provider: GPUStatsProviding = AGXGPUStatsProvider()) {
        self.provider = provider
    }

    func refresh() throws -> GPUUsage {
        let stats = try provider.currentStats()
        let fraction = Double(stats.deviceUtilizationPercent) / 100
        return GPUUsage(deviceUtilization: min(max(fraction, 0), 1))
    }
}
