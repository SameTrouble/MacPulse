import Foundation

final class CPUTemperatureMetric: Metric {
    static let metricID = "cpu-temperature"

    let id = CPUTemperatureMetric.metricID
    let displayNameKey = LocalizationKey.metricCPUTemperatureName
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
        guard let usage else {
            return MetricSample(text: "\(Self.prefix) --", fraction: nil)
        }
        return MetricSample(
            text: "\(Self.prefix) \(TemperatureUsageDisplay.celsius(usage.cpuCelsius))",
            fraction: TemperatureUsageDisplay.fraction(celsius: usage.cpuCelsius)
        )
    }

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [localization.text(.temperatureCPU, "--")]
        }
        return [localization.text(.temperatureCPU, TemperatureUsageDisplay.celsius(usage.cpuCelsius))]
    }

    func widestDisplayText() -> String {
        "\(Self.prefix) \(TemperatureUsageDisplay.widestText)"
    }

    private static let prefix = "CPU"
}
