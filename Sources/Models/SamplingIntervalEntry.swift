import Foundation

enum SamplingIntervalEntry: Equatable, Identifiable {
    case single(metricID: String, displayNameKey: LocalizationKey)
    case temperature

    var id: String {
        switch self {
        case let .single(metricID, _):
            metricID
        case .temperature:
            "temperature"
        }
    }
    var displayNameKey: LocalizationKey {
        switch self {
        case let .single(_, displayNameKey):
            displayNameKey
        case .temperature:
            .metricTemperatureName
        }
    }

    static func entries(from metrics: [Metric]) -> [SamplingIntervalEntry] {
        let hasCPU = metrics.contains { $0.id == CPUTemperatureMetric.metricID }
        let hasGPU = metrics.contains { $0.id == GPUTemperatureMetric.metricID }
        let collapseTemperature = hasCPU && hasGPU
        var entries: [SamplingIntervalEntry] = []
        var didEmitTemperature = false
        for metric in metrics {
            let isTemperature =
                metric.id == CPUTemperatureMetric.metricID || metric.id == GPUTemperatureMetric.metricID
            if collapseTemperature, isTemperature {
                if !didEmitTemperature {
                    entries.append(.temperature)
                    didEmitTemperature = true
                }
                continue
            }
            entries.append(.single(metricID: metric.id, displayNameKey: metric.displayNameKey))
        }
        return entries
    }
}

extension AppConfiguration {
    mutating func samplingInterval(for entry: SamplingIntervalEntry, registry: MetricRegistry) -> TimeInterval {
        switch entry {
        case let .single(metricID, _):
            guard let metric = registry.metric(id: metricID) else { return SamplingInterval.range.lowerBound }
            return samplingInterval(for: metric)
        case .temperature:
            let cpuID = CPUTemperatureMetric.metricID
            let gpuID = GPUTemperatureMetric.metricID
            let cpuDefault = registry.metric(id: cpuID)?.defaultSamplingInterval ?? 5
            let gpuDefault = registry.metric(id: gpuID)?.defaultSamplingInterval ?? 5
            let cpuInterval = samplingIntervals[cpuID] ?? cpuDefault
            let gpuInterval = samplingIntervals[gpuID] ?? gpuDefault
            if cpuInterval != gpuInterval {
                samplingIntervals[cpuID] = cpuInterval
                samplingIntervals[gpuID] = cpuInterval
            }
            return cpuInterval
        }
    }

    mutating func setSamplingInterval(_ interval: TimeInterval, for entry: SamplingIntervalEntry) {
        switch entry {
        case let .single(metricID, _):
            samplingIntervals[metricID] = interval
        case .temperature:
            samplingIntervals[CPUTemperatureMetric.metricID] = interval
            samplingIntervals[GPUTemperatureMetric.metricID] = interval
        }
    }
}
