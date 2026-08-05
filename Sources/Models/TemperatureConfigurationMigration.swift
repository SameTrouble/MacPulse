import Foundation

extension AppConfiguration {
    static let legacyTemperatureMetricID = "temperature"

    func migratingLegacyTemperature() -> AppConfiguration {
        var migrated = self
        migrated.placeholders = placeholders.map(Self.migratePlaceholder)
        Self.migrateDictionaryKey(
            in: &migrated.samplingIntervals,
            from: Self.legacyTemperatureMetricID,
            to: [CPUTemperatureMetric.metricID, GPUTemperatureMetric.metricID]
        )
        Self.migrateDictionaryKey(
            in: &migrated.colorBands,
            from: Self.legacyTemperatureMetricID,
            to: [CPUTemperatureMetric.metricID, GPUTemperatureMetric.metricID]
        )
        return migrated
    }

    func normalizingTemperatureIntervals() -> AppConfiguration {
        var normalized = self
        let cpuID = CPUTemperatureMetric.metricID
        let gpuID = GPUTemperatureMetric.metricID
        if let cpuInterval = samplingIntervals[cpuID] {
            normalized.samplingIntervals[gpuID] = cpuInterval
        } else {
            normalized.samplingIntervals[gpuID] = nil
        }
        return normalized
    }

    private static func migratePlaceholder(_ placeholder: Placeholder) -> Placeholder {
        var migrated = placeholder
        migrated.items = placeholder.items.flatMap(migrateCarouselItem)
        migrated.menuMetricIDs = placeholder.menuMetricIDs.flatMap { metricID in
            guard metricID == legacyTemperatureMetricID else { return [metricID] }
            return [CPUTemperatureMetric.metricID, GPUTemperatureMetric.metricID]
        }
        return migrated
    }

    private static func migrateCarouselItem(_ item: CarouselItem) -> [CarouselItem] {
        guard item.metricID == legacyTemperatureMetricID else { return [item] }
        do {
            let cpu = try CarouselItem(metricID: CPUTemperatureMetric.metricID, style: item.style, duration: item.duration)
            let gpu = try CarouselItem(metricID: GPUTemperatureMetric.metricID, style: item.style, duration: item.duration)
            return [cpu, gpu]
        } catch {
            return [item]
        }
    }

    private static func migrateDictionaryKey<Value>(
        in dictionary: inout [String: Value],
        from legacyKey: String,
        to newKeys: [String]
    ) {
        guard let value = dictionary.removeValue(forKey: legacyKey) else { return }
        for key in newKeys {
            dictionary[key] = value
        }
    }
}
