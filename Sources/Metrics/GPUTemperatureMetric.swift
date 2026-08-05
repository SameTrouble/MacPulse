import Foundation

final class GPUTemperatureMetric: Metric {
    static let metricID = "gpu-temperature"

    let id = GPUTemperatureMetric.metricID
    let displayNameKey = LocalizationKey.metricGPUTemperatureName
    let symbolName = "thermometer.medium"
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
        guard let usage, let gpuCelsius = usage.gpuCelsius else {
            return MetricSample(text: "\(Self.prefix) --", fraction: nil)
        }
        return MetricSample(
            text: "\(Self.prefix) \(TemperatureUsageDisplay.celsius(gpuCelsius))",
            fraction: TemperatureUsageDisplay.fraction(celsius: gpuCelsius)
        )
    }

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [localization.text(.temperatureGPU, "--")]
        }
        if let gpuCelsius = usage.gpuCelsius {
            return [localization.text(.temperatureGPU, TemperatureUsageDisplay.celsius(gpuCelsius))]
        }
        return [localization.text(.temperatureGPU, "--")]
    }

    func widestDisplayText() -> String {
        "\(Self.prefix) \(TemperatureUsageDisplay.widestText)"
    }

    private static let prefix = "GPU"
}
