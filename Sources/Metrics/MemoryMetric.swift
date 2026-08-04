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
        usage.map { MetricSample(text: MemoryUsageDisplay.buttonTitle(for: $0), fraction: $0.fraction) }
    }

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [
                localization.text(.memoryUsed, "--"),
                localization.text(.memoryTotal, "--"),
                localization.text(.memoryPressure, "--")
            ]
        }
        return [
            localization.text(.memoryUsed, MemoryUsageDisplay.gigabytes(usage.usedBytes)),
            localization.text(.memoryTotal, MemoryUsageDisplay.gigabytes(usage.totalBytes)),
            localization.text(
                .memoryPressure,
                MemoryUsageDisplay.pressureLabel(usage.pressure, localizedBy: localization)
            )
        ]
    }

    func widestDisplayText(for style: MetricStyle) -> String {
        "999.9 GB"
    }
}
