import Foundation

final class GPUMetric: Metric {
    static let metricID = "gpu"

    let id = GPUMetric.metricID
    let displayName = "GPU"
    let symbolName = "gauge.with.needle"
    let supportedStyles: Set<MetricStyle> = [.iconAndText, .text]

    private let sampler: GPUSampler
    private var usage: GPUUsage?

    init(sampler: GPUSampler = GPUSampler()) {
        self.sampler = sampler
    }

    func refresh() {
        do {
            usage = try sampler.refresh()
        } catch {
            usage = nil
        }
    }

    func currentSample() -> MetricSample? {
        usage.map { MetricSample(text: GPUUsageDisplay.buttonTitle(for: $0), fraction: $0.deviceUtilization) }
    }

    func menuLines() -> [String] {
        guard let usage else {
            return ["GPU 利用率：--"]
        }
        return ["GPU 利用率：\(GPUUsageDisplay.percent(usage.deviceUtilization))"]
    }
}
