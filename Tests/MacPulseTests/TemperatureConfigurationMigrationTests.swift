@testable import MacPulse
import XCTest

final class TemperatureConfigurationMigrationTests: XCTestCase {
    private let legacyID = "temperature"
    private let cpuID = CPUTemperatureMetric.metricID
    private let gpuID = GPUTemperatureMetric.metricID

    func testMigratingConfigurationWithoutLegacyTemperatureIsUnchanged() throws {
        let item = try CarouselItem(metricID: "cpu", style: .text, duration: 5)
        var configuration = AppConfiguration(
            placeholders: [Placeholder(id: UUID(), items: [item], menuMetricIDs: ["cpu"])]
        )
        configuration.samplingIntervals["cpu"] = 3
        configuration.colorBands["cpu"] = [try ColorBand(upperBound: 1, color: .green)]

        let migrated = configuration.migratingLegacyTemperature()

        XCTAssertEqual(migrated, configuration)
    }

    func testMigratesCarouselTemperatureItemIntoAdjacentCPUThenGPU() throws {
        let before = try CarouselItem(metricID: "cpu", style: .iconAndText, duration: 4)
        let temperature = try CarouselItem(metricID: legacyID, style: .text, duration: 7)
        let after = try CarouselItem(metricID: "memory", style: .progressBar, duration: 2)
        let configuration = AppConfiguration(
            placeholders: [Placeholder(id: UUID(), items: [before, temperature, after])]
        )

        let migrated = configuration.migratingLegacyTemperature()
        let items = migrated.placeholders[0].items

        XCTAssertEqual(items.count, 4)
        XCTAssertEqual(items[0], before)
        XCTAssertEqual(items[1].metricID, cpuID)
        XCTAssertEqual(items[1].style, MetricStyle.text)
        XCTAssertEqual(items[1].duration, 7)
        XCTAssertEqual(items[2].metricID, gpuID)
        XCTAssertEqual(items[2].style, MetricStyle.text)
        XCTAssertEqual(items[2].duration, 7)
        XCTAssertEqual(items[3], after)
        XCTAssertNotEqual(items[1].id, temperature.id)
        XCTAssertNotEqual(items[2].id, temperature.id)
        XCTAssertNotEqual(items[1].id, items[2].id)
    }

    func testMigratesMenuMetricIDsReplacingTemperatureWithCPUThenGPU() {
        let configuration = AppConfiguration(
            placeholders: [
                Placeholder(
                    id: UUID(),
                    items: [],
                    menuMetricIDs: ["cpu", legacyID, "memory"]
                )
            ]
        )

        let migrated = configuration.migratingLegacyTemperature()

        XCTAssertEqual(
            migrated.placeholders[0].menuMetricIDs,
            ["cpu", cpuID, gpuID, "memory"]
        )
    }

    func testMigratesSamplingIntervalsAndColorBandsFromTemperatureKey() throws {
        var configuration = AppConfiguration(placeholders: [])
        configuration.samplingIntervals[legacyID] = 8
        configuration.samplingIntervals["cpu"] = 2
        let bands = [try ColorBand(upperBound: 0.5, color: .orange), try ColorBand(upperBound: 1, color: .red)]
        configuration.colorBands[legacyID] = bands
        configuration.colorBands["cpu"] = [try ColorBand(upperBound: 1, color: .blue)]

        let migrated = configuration.migratingLegacyTemperature()

        XCTAssertNil(migrated.samplingIntervals[legacyID])
        XCTAssertEqual(migrated.samplingIntervals[cpuID], 8)
        XCTAssertEqual(migrated.samplingIntervals[gpuID], 8)
        XCTAssertEqual(migrated.samplingIntervals["cpu"], 2)
        XCTAssertNil(migrated.colorBands[legacyID])
        XCTAssertEqual(migrated.colorBands[cpuID], bands)
        XCTAssertEqual(migrated.colorBands[gpuID], bands)
        XCTAssertEqual(migrated.colorBands["cpu"]?.map(\.color), [PaletteColor.blue])
    }
}
