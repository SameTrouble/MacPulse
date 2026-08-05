import Foundation

final class GPUMetric: SampledMetric<GPUUsage, GPUSampler> {
    static let metricID = "gpu"

    init(sampler: GPUSampler = GPUSampler()) {
        super.init(
            id: GPUMetric.metricID,
            displayNameKey: .metricGPUName,
            symbolName: "gauge.with.needle",
            supportedStyles: [.iconAndText, .text, .progressBar],
            sampler: sampler
        )
    }

    override func makeSample(from usage: GPUUsage) -> MetricSample? {
        MetricSample(text: ValueFormatting.percent(usage.deviceUtilization), fraction: usage.deviceUtilization)
    }

    override func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [localization.text(.gpuUtilization, "--")]
        }
        return [localization.text(.gpuUtilization, ValueFormatting.percent(usage.deviceUtilization))]
    }

    override func widestDisplayText() -> String {
        ValueFormatting.widestPercent
    }
}
