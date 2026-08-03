import Foundation

final class MemoryMetric: Metric {
    static let metricID = "memory"

    let id = MemoryMetric.metricID
    let displayName = "内存"
    let symbolName = "memorychip"
    let supportedStyles: Set<MetricStyle> = [.iconAndText, .text, .progressBar]

    private let sampler: MemorySampler
    private var usage: MemoryUsage?

    init(sampler: MemorySampler = MemorySampler()) {
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
        usage.map { MetricSample(text: MemoryUsageDisplay.buttonTitle(for: $0), fraction: $0.fraction) }
    }

    func menuLines() -> [String] {
        guard let usage else {
            return ["已用：--", "总量：--", "压力等级：--"]
        }
        return [
            "已用：\(MemoryUsageDisplay.gigabytes(usage.usedBytes))",
            "总量：\(MemoryUsageDisplay.gigabytes(usage.totalBytes))",
            "压力等级：\(MemoryUsageDisplay.pressureLabel(usage.pressure))"
        ]
    }
}
