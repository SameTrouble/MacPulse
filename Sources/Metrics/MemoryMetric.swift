import Foundation

final class MemoryMetric: Metric {
    static let metricID = "memory"

    let id = MemoryMetric.metricID
    let displayNameKey = LocalizationKey.metricMemoryName
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
        usage.map { MetricSample(text: ValueFormatting.gigabytes($0.usedBytes), fraction: $0.fraction) }
    }

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
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

    func widestDisplayText() -> String {
        ValueFormatting.widestGigabytes
    }
}
