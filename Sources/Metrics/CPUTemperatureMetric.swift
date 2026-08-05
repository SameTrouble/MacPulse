import Foundation

final class CPUTemperatureMetric: TemperatureMetric {
    static let metricID = "cpu-temperature"

    init(sampler: TemperatureSampler = TemperatureSampler()) {
        super.init(
            id: CPUTemperatureMetric.metricID,
            prefix: "CPU",
            displayNameKey: .metricCPUTemperatureName,
            symbolName: "thermometer",
            menuKey: .temperatureCPU,
            sampler: sampler
        )
    }

    override func celsiusValue(from usage: TemperatureUsage) -> Double? {
        usage.cpuCelsius
    }
}
