@testable import MacPulse
import XCTest

final class SamplingIntervalEntriesTests: XCTestCase {
    private func registry(_ metrics: [FakeMetric]) -> MetricRegistry {
        let registry = MetricRegistry()
        for metric in metrics {
            registry.register(metric)
        }
        return registry
    }

    func testCollapsesCPUAndGPUTemperatureIntoOneEntry() {
        let metrics: [Metric] = [
            FakeMetric(id: "cpu"),
            FakeMetric(id: CPUTemperatureMetric.metricID, displayNameKey: .metricCPUTemperatureName),
            FakeMetric(id: GPUTemperatureMetric.metricID, displayNameKey: .metricGPUTemperatureName),
            FakeMetric(id: "memory", displayNameKey: .metricMemoryName)
        ]

        let entries = SamplingIntervalEntry.entries(from: metrics)

        XCTAssertEqual(entries.count, 3)
        XCTAssertEqual(entries[0], .single(metricID: "cpu", displayNameKey: .metricCPUName))
        XCTAssertEqual(entries[1], .temperature)
        XCTAssertEqual(entries[2], .single(metricID: "memory", displayNameKey: .metricMemoryName))
    }

    func testKeepsLoneTemperatureMetricAsSingleEntry() {
        let metrics: [Metric] = [
            FakeMetric(id: CPUTemperatureMetric.metricID, displayNameKey: .metricCPUTemperatureName)
        ]

        let entries = SamplingIntervalEntry.entries(from: metrics)

        XCTAssertEqual(
            entries,
            [.single(metricID: CPUTemperatureMetric.metricID, displayNameKey: .metricCPUTemperatureName)]
        )
    }

    func testReadingTemperatureIntervalUsesCPUWhenValuesDifferAndLeavesConfigurationUnchanged() {
        let configuration = AppConfiguration(placeholders: [])
        var withDivergentValues = configuration
        withDivergentValues.samplingIntervals[CPUTemperatureMetric.metricID] = 4
        withDivergentValues.samplingIntervals[GPUTemperatureMetric.metricID] = 9
        let registry = registry([
            FakeMetric(id: CPUTemperatureMetric.metricID, defaultSamplingInterval: 5),
            FakeMetric(id: GPUTemperatureMetric.metricID, defaultSamplingInterval: 5)
        ])
        let snapshot = withDivergentValues

        let interval = withDivergentValues.samplingInterval(for: .temperature, registry: registry)

        XCTAssertEqual(interval, 4)
        XCTAssertEqual(withDivergentValues, snapshot)
    }

    func testReadingSamplingIntervalIsPureAndDoesNotMutateConfiguration() {
        let configuration = AppConfiguration(placeholders: [])
        var withDivergentValues = configuration
        withDivergentValues.samplingIntervals[CPUTemperatureMetric.metricID] = 4
        withDivergentValues.samplingIntervals[GPUTemperatureMetric.metricID] = 9
        let registry = registry([
            FakeMetric(id: CPUTemperatureMetric.metricID, defaultSamplingInterval: 5),
            FakeMetric(id: GPUTemperatureMetric.metricID, defaultSamplingInterval: 5)
        ])
        let snapshot = withDivergentValues

        _ = withDivergentValues.samplingInterval(for: .temperature, registry: registry)

        XCTAssertEqual(withDivergentValues, snapshot)
    }

    func testSettingTemperatureIntervalWritesBothIDs() {
        var configuration = AppConfiguration(placeholders: [])

        configuration.setSamplingInterval(7, for: .temperature)

        XCTAssertEqual(configuration.samplingIntervals[CPUTemperatureMetric.metricID], 7)
        XCTAssertEqual(configuration.samplingIntervals[GPUTemperatureMetric.metricID], 7)
    }

    func testSingleEntryIntervalUsesMetricDefaultWhenUnset() {
        var configuration = AppConfiguration(placeholders: [])
        let registry = registry([FakeMetric(id: "cpu", defaultSamplingInterval: 3)])
        let entry = SamplingIntervalEntry.single(metricID: "cpu", displayNameKey: .metricCPUName)

        XCTAssertEqual(configuration.samplingInterval(for: entry, registry: registry), 3)

        configuration.setSamplingInterval(11, for: entry)

        XCTAssertEqual(configuration.samplingIntervals["cpu"], 11)
    }
}
