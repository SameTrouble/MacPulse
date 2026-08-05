import Foundation

final class MemoryMetric: SampledMetric<MemoryUsage, MemorySampler> {
    static let metricID = "memory"

    init(sampler: MemorySampler = MemorySampler()) {
        super.init(
            id: MemoryMetric.metricID,
            displayNameKey: .metricMemoryName,
            symbolName: "memorychip",
            supportedStyles: [.iconAndText, .text, .progressBar],
            sampler: sampler
        )
    }

    override func makeSample(from usage: MemoryUsage) -> MetricSample? {
        MetricSample(text: ValueFormatting.gigabytes(usage.usedBytes), fraction: usage.fraction)
    }

    override func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [
                localization.text(.memoryUsed, ValueFormatting.fallback),
                localization.text(.memoryTotal, ValueFormatting.fallback)
            ]
        }
        return [
            localization.text(.memoryUsed, ValueFormatting.gigabytes(usage.usedBytes)),
            localization.text(.memoryTotal, ValueFormatting.gigabytes(usage.totalBytes))
        ]
    }

    override func widestDisplayText() -> String {
        ValueFormatting.widestGigabytes
    }
}
