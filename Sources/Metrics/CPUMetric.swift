import Foundation

final class CPUMetric: Metric {
    static let metricID = "cpu"

    let id = CPUMetric.metricID
    let displayNameKey = LocalizationKey.metricCPUName
    let symbolName = "cpu.fill"
    let supportedStyles: Set<MetricStyle> = [.iconAndText, .text, .progressBar]

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

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [localization.text(.cpuOverall, "--")]
        }
        var lines = [localization.text(.cpuOverall, CPUUsageDisplay.percent(usage.overall))]
        for (index, core) in usage.perCore.enumerated() {
            lines.append(localization.text(.cpuCore, index + 1, CPUUsageDisplay.percent(core)))
        }
        return lines
    }

    func widestDisplayText(for style: MetricStyle) -> String {
        "100%"
    }
}
