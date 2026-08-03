import Foundation

final class CPUMetric: Metric {
    static let metricID = "cpu"

    let id = CPUMetric.metricID
    let displayName = "CPU"
    let symbolName = "cpu.fill"
    let supportedStyles: Set<MetricStyle> = [.iconAndText, .text]

    private let sampler: CPUUsageSampler
    private var sample: MetricSample?
    private var usage: CPUUsage?

    init(sampler: CPUUsageSampler = CPUUsageSampler()) {
        self.sampler = sampler
    }

    func refresh() {
        do {
            usage = try sampler.refresh()
        } catch {
            usage = nil
        }
        sample = usage.map { usage in
            MetricSample(text: CPUUsageDisplay.percent(usage.overall), fraction: usage.overall)
        }
    }

    func currentSample() -> MetricSample? {
        sample
    }

    func menuLines() -> [String] {
        guard let usage else {
            return ["总体 CPU：--"]
        }
        var lines = ["总体 CPU：\(CPUUsageDisplay.percent(usage.overall))"]
        for (index, core) in usage.perCore.enumerated() {
            lines.append("核心 \(index + 1)：\(CPUUsageDisplay.percent(core))")
        }
        return lines
    }
}
