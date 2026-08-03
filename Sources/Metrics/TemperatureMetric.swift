import Foundation

final class TemperatureMetric: Metric {
    static let metricID = "temperature"

    let id = TemperatureMetric.metricID
    let displayName = "温度"
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

    func menuLines() -> [String] {
        guard let usage else {
            return ["CPU：--", "GPU：--"]
        }
        var lines = ["CPU：\(TemperatureUsageDisplay.celsius(usage.cpuCelsius))"]
        if let gpuCelsius = usage.gpuCelsius {
            lines.append("GPU：\(TemperatureUsageDisplay.celsius(gpuCelsius))")
        } else {
            lines.append("GPU：--")
        }
        return lines
    }
}
