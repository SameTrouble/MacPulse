@testable import MacPulse
import XCTest

final class ConfigurationModelTests: XCTestCase {
    private func registry() -> MetricRegistry {
        let registry = MetricRegistry()
        registry.register(FakeMetric(id: "cpu"))
        registry.register(FakeMetric(id: "gpu", defaultSamplingInterval: 5))
        return registry
    }

    private func makeModel(defaults: UserDefaults? = nil) -> ConfigurationModel {
        ConfigurationModel(
            registry: registry(),
            store: ConfigurationStore(defaults: defaults ?? UserDefaults.standard),
            fallback: AppConfiguration(placeholders: [])
        )
    }

    func testLoadsStoredConfigurationAtInit() throws {
        let defaults = UserDefaults(suiteName: UUID().uuidString) ?? .standard
        let item = try CarouselItem(metricID: "cpu", style: .iconAndText)
        var stored = AppConfiguration(placeholders: [Placeholder(id: UUID(), items: [item])])
        stored.samplingIntervals["cpu"] = 4
        try ConfigurationStore(defaults: defaults).save(stored)

        let model = makeModel(defaults: defaults)

        XCTAssertEqual(model.committed, stored)
        XCTAssertEqual(model.draft, stored)
    }

    func testMigratesLegacyTemperatureOnLoadAndPersists() throws {
        let defaults = UserDefaults(suiteName: UUID().uuidString) ?? .standard
        let temperature = try CarouselItem(metricID: "temperature", style: .text, duration: 6)
        var stored = AppConfiguration(
            placeholders: [
                Placeholder(id: UUID(), items: [temperature], menuMetricIDs: ["temperature"])
            ]
        )
        stored.samplingIntervals["temperature"] = 9
        stored.colorBands["temperature"] = [try ColorBand(upperBound: 1, color: .yellow)]
        try ConfigurationStore(defaults: defaults).save(stored)

        let registry = MetricRegistry()
        registry.register(FakeMetric(id: "cpu"))
        registry.register(FakeMetric(id: CPUTemperatureMetric.metricID, supportedStyles: [.iconAndText, .text]))
        registry.register(FakeMetric(id: GPUTemperatureMetric.metricID, supportedStyles: [.iconAndText, .text]))
        let model = ConfigurationModel(
            registry: registry,
            store: ConfigurationStore(defaults: defaults),
            fallback: AppConfiguration(placeholders: [])
        )

        let expected = stored.migratingLegacyTemperature()
        XCTAssertEqual(model.committed.placeholders[0].menuMetricIDs, expected.placeholders[0].menuMetricIDs)
        XCTAssertEqual(model.committed.placeholders[0].items.map(\.metricID), expected.placeholders[0].items.map(\.metricID))
        XCTAssertEqual(model.committed.samplingIntervals, expected.samplingIntervals)
        XCTAssertEqual(model.committed.colorBands.keys.sorted(), expected.colorBands.keys.sorted())
        XCTAssertEqual(ConfigurationStore(defaults: defaults).load(), model.committed)
    }

    func testNormalizesDivergentTemperatureIntervalsOnLoadAndPersists() throws {
        let defaults = UserDefaults(suiteName: UUID().uuidString) ?? .standard
        var stored = AppConfiguration(placeholders: [])
        stored.samplingIntervals[CPUTemperatureMetric.metricID] = 4
        stored.samplingIntervals[GPUTemperatureMetric.metricID] = 9
        try ConfigurationStore(defaults: defaults).save(stored)

        let registry = MetricRegistry()
        registry.register(FakeMetric(id: CPUTemperatureMetric.metricID, defaultSamplingInterval: 5))
        registry.register(FakeMetric(id: GPUTemperatureMetric.metricID, defaultSamplingInterval: 5))
        let model = ConfigurationModel(
            registry: registry,
            store: ConfigurationStore(defaults: defaults),
            fallback: AppConfiguration(placeholders: [])
        )

        XCTAssertEqual(model.committed.samplingIntervals[CPUTemperatureMetric.metricID], 4)
        XCTAssertEqual(model.committed.samplingIntervals[GPUTemperatureMetric.metricID], 4)
        XCTAssertEqual(ConfigurationStore(defaults: defaults).load(), model.committed)
    }

    func testNormalizesTemperatureIntervalsWhenCPUUnsetDropsGPUValue() throws {
        let defaults = UserDefaults(suiteName: UUID().uuidString) ?? .standard
        var stored = AppConfiguration(placeholders: [])
        stored.samplingIntervals[GPUTemperatureMetric.metricID] = 9
        try ConfigurationStore(defaults: defaults).save(stored)

        let registry = MetricRegistry()
        registry.register(FakeMetric(id: CPUTemperatureMetric.metricID, defaultSamplingInterval: 5))
        registry.register(FakeMetric(id: GPUTemperatureMetric.metricID, defaultSamplingInterval: 5))
        let model = ConfigurationModel(
            registry: registry,
            store: ConfigurationStore(defaults: defaults),
            fallback: AppConfiguration(placeholders: [])
        )

        XCTAssertNil(model.committed.samplingIntervals[GPUTemperatureMetric.metricID])
    }

    func testFallsBackToDefaultWhenStoreIsEmpty() {
        let fallback = AppConfiguration(placeholders: [Placeholder(id: UUID(), items: [])])
        let model = ConfigurationModel(
            registry: registry(),
            store: ConfigurationStore(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard),
            fallback: fallback
        )

        XCTAssertEqual(model.committed, fallback)
    }

    func testFallsBackToDefaultWhenStoredConfigurationIsInvalid() throws {
        let defaults = UserDefaults(suiteName: UUID().uuidString) ?? .standard
        let invalid = AppConfiguration(placeholders: [Placeholder(id: UUID(), items: [try item(metricID: "missing")])])
        try ConfigurationStore(defaults: defaults).save(invalid)
        let fallback = AppConfiguration(placeholders: [Placeholder(id: UUID(), items: [])])

        let model = ConfigurationModel(registry: registry(), store: ConfigurationStore(defaults: defaults), fallback: fallback)

        XCTAssertEqual(model.committed, fallback)
    }

    private func item(metricID: String = "cpu") throws -> CarouselItem {
        try CarouselItem(metricID: metricID, style: .iconAndText)
    }

    func testCommitAppliesDraftAndPublishesIt() throws {
        let committed = expectation(description: "committed")
        let model = makeModel()
        model.onCommit = { _ in committed.fulfill() }
        model.draft.placeholders.append(Placeholder(id: UUID(), items: [try item()]))

        model.commit()

        wait(for: [committed], timeout: 1)
        XCTAssertEqual(model.committed, model.draft)
    }

    func testCommitRejectsUnknownMetric() throws {
        let model = makeModel()
        model.draft.placeholders = [Placeholder(id: UUID(), items: [try item(metricID: "missing")])]

        XCTAssertFalse(model.commit())
    }

    func testCommitRejectsOutOfRangeSamplingInterval() {
        let model = makeModel()
        model.draft.samplingIntervals["cpu"] = 0.5

        XCTAssertFalse(model.commit())
    }

    func testRejectingCommitKeepsCommittedConfiguration() throws {
        let model = makeModel()
        let original = model.committed
        model.draft.placeholders = [Placeholder(id: UUID(), items: [try item(metricID: "missing")])]

        model.commit()

        XCTAssertEqual(model.committed, original)
    }

    func testCommitPersistsConfigurationToStore() throws {
        let defaults = UserDefaults(suiteName: UUID().uuidString) ?? .standard
        let model = makeModel(defaults: defaults)
        model.draft.placeholders = [Placeholder(id: UUID(), items: [try item()])]

        model.commit()

        XCTAssertEqual(ConfigurationStore(defaults: defaults).load(), model.committed)
    }

    func testDraftIsIndependentCopyOfCommitted() {
        let model = makeModel()
        let countBefore = model.committed.placeholders.count

        model.draft.placeholders.append(Placeholder(id: UUID(), items: []))

        XCTAssertEqual(model.committed.placeholders.count, countBefore)
        XCTAssertTrue(model.isDirty)
    }

    func testRevertRestoresDraftFromCommitted() {
        let model = makeModel()
        model.draft.placeholders = []

        model.revert()

        XCTAssertEqual(model.draft, model.committed)
        XCTAssertFalse(model.isDirty)
    }
}
