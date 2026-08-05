import Foundation

final class CPUMetric: SampledMetric<CPUUsage?, CPUUsageSampler> {
    static let metricID = "cpu"

    init(sampler: CPUUsageSampler = CPUUsageSampler()) {
        super.init(
            id: CPUMetric.metricID,
            displayNameKey: .metricCPUName,
            symbolName: "cpu.fill",
            supportedStyles: [.iconAndText, .text, .progressBar],
            sampler: sampler
        )
    }

    override func makeSample(from usage: CPUUsage?) -> MetricSample? {
        usage.map { MetricSample(text: ValueFormatting.percent($0.overall), fraction: $0.overall) }
    }

    override func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage, let usage = usage else {
            return [localization.text(.cpuOverall, "--")]
        }
        var lines = [localization.text(.cpuOverall, ValueFormatting.percent(usage.overall))]
        for (index, core) in usage.perCore.enumerated() {
            lines.append(localization.text(.cpuCore, index + 1, ValueFormatting.percent(core)))
        }
        return lines
    }

    override func widestDisplayText() -> String {
        ValueFormatting.widestPercent
    }
}
