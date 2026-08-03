import Foundation

final class TemperatureMetric: Metric {
    static let metricID = "temperature"

    let id = TemperatureMetric.metricID
    let displayNameKey = LocalizationKey.metricTemperatureName
    let symbolName = "thermometer"
    let supportedStyles: Set<MetricStyle> = [.iconAndText, .text]
    let defaultSamplingInterval: TimeInterval = 5

    private let sampler: TemperatureSampler
    private var usage: TemperatureUsage?

    init(sampler: TemperatureSampler = TemperatureSampler()) {
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
        usage.map { MetricSample(text: TemperatureUsageDisplay.buttonTitle(for: $0), fraction: nil) }
    }

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [localization.text(.temperatureCPU, "--"), localization.text(.temperatureGPU, "--")]
        }
        var lines = [localization.text(.temperatureCPU, TemperatureUsageDisplay.celsius(usage.cpuCelsius))]
        if let gpuCelsius = usage.gpuCelsius {
            lines.append(localization.text(.temperatureGPU, TemperatureUsageDisplay.celsius(gpuCelsius)))
        } else {
            lines.append(localization.text(.temperatureGPU, "--"))
        }
        return lines
    }
}
