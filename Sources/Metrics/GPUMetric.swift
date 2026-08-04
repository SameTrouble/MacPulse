import Foundation

final class GPUMetric: Metric {
    static let metricID = "gpu"

    let id = GPUMetric.metricID
    let displayNameKey = LocalizationKey.metricGPUName
    let symbolName = "gauge.with.needle"
    let supportedStyles: Set<MetricStyle> = [.iconAndText, .text, .progressBar]

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

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [localization.text(.gpuUtilization, "--")]
        }
        return [localization.text(.gpuUtilization, GPUUsageDisplay.percent(usage.deviceUtilization))]
    }

    func widestDisplayText(for style: MetricStyle) -> String {
        "100%"
    }
}
