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
            return MetricSample(text: "\(Self.prefix) \(ValueFormatting.fallback)", fraction: nil)
        }
        return MetricSample(
            text: "\(Self.prefix) \(ValueFormatting.celsius(gpuCelsius))",
            fraction: ValueFormatting.fraction(celsius: gpuCelsius)
        )
    }

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [localization.text(.temperatureGPU, ValueFormatting.fallback)]
        }
        if let gpuCelsius = usage.gpuCelsius {
            return [localization.text(.temperatureGPU, ValueFormatting.celsius(gpuCelsius))]
        }
        return [localization.text(.temperatureGPU, ValueFormatting.fallback)]
    }

    func widestDisplayText() -> String {
        "\(Self.prefix) \(ValueFormatting.widestCelsius)"
    }

    private static let prefix = "GPU"
}
