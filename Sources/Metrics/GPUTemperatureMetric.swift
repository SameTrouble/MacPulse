import Foundation

final class GPUTemperatureMetric: TemperatureMetric {
    static let metricID = "gpu-temperature"

    init(sampler: TemperatureSampler = TemperatureSampler()) {
        super.init(
            id: GPUTemperatureMetric.metricID,
            prefix: "GPU",
            displayNameKey: .metricGPUTemperatureName,
            symbolName: "thermometer.medium",
            menuKey: .temperatureGPU,
            sampler: sampler
        )
    }

    override func celsiusValue(from usage: TemperatureUsage) -> Double? {
        usage.gpuCelsius
    }
}
