@testable import MacPulse
import XCTest

final class ConfigurationValidationTests: XCTestCase {
    private func registry() -> MetricRegistry {
        let registry = MetricRegistry()
        registry.register(FakeMetric(id: "cpu", supportedStyles: [.iconAndText, .text]))
        registry.register(FakeMetric(id: "memory", supportedStyles: [.iconAndText]))
        return registry
    }

    private func configuration(items: [CarouselItem], menuMetricIDs: [String] = []) -> AppConfiguration {
        AppConfiguration(placeholders: [Placeholder(id: UUID(), items: items, menuMetricIDs: menuMetricIDs)])
    }

    func testValidConfigurationPasses() throws {
        let config = configuration(items: [
            try CarouselItem(metricID: "cpu", style: .iconAndText),
            try CarouselItem(metricID: "memory", style: .iconAndText)
        ])

        XCTAssertEqual(config.validationErrors(against: registry()), [])
    }

    func testUnknownMetricIsRejected() throws {
        let config = configuration(items: [try CarouselItem(metricID: "gpu", style: .text)])

        let errors = config.validationErrors(against: registry())

        XCTAssertEqual(errors, [.unknownMetric("gpu")])
    }

    func testUnknownMenuMetricIsRejected() throws {
        let config = configuration(
            items: [try CarouselItem(metricID: "cpu", style: .iconAndText)],
            menuMetricIDs: ["gpu", "cpu"]
        )

        let errors = config.validationErrors(against: registry())

        XCTAssertEqual(errors, [.unknownMetric("gpu")])
    }

    func testKnownMenuMetricsPass() throws {
        let config = configuration(
            items: [try CarouselItem(metricID: "cpu", style: .iconAndText)],
            menuMetricIDs: ["cpu", "memory"]
        )

        XCTAssertEqual(config.validationErrors(against: registry()), [])
    }

    func testUnsupportedStyleIsRejected() throws {
        let config = configuration(items: [try CarouselItem(metricID: "memory", style: .text)])

        let errors = config.validationErrors(against: registry())

        XCTAssertEqual(errors, [.unsupportedStyle(metricID: "memory", style: .text)])
    }

    func testReportsEveryOffendingEntry() throws {
        let config = configuration(items: [
            try CarouselItem(metricID: "gpu", style: .text),
            try CarouselItem(metricID: "memory", style: .text),
            try CarouselItem(metricID: "cpu", style: .iconAndText)
        ])

        let errors = config.validationErrors(against: registry())

        XCTAssertEqual(errors, [
            .unknownMetric("gpu"),
            .unsupportedStyle(metricID: "memory", style: .text)
        ])
    }

    func testItemDurationOutOfRangeIsRejected() throws {
        var badItem = try CarouselItem(metricID: "cpu", style: .iconAndText)
        badItem.duration = 0
        let config = configuration(items: [badItem])

        let errors = config.validationErrors(against: registry())

        XCTAssertEqual(errors, [.durationOutOfRange(metricID: "cpu", duration: 0)])
    }

    func testSamplingIntervalWithinRangePasses() {
        var config = configuration(items: [])
        config.samplingIntervals["cpu"] = 1
        config.samplingIntervals["memory"] = 60

        XCTAssertEqual(config.validationErrors(against: registry()), [])
    }

    func testSamplingIntervalOutOfRangeIsRejected() {
        var config = configuration(items: [])
        config.samplingIntervals["cpu"] = 61

        let errors = config.validationErrors(against: registry())

        XCTAssertEqual(errors, [.samplingIntervalOutOfRange(metricID: "cpu", interval: 61)])
    }

    func testColorRuleThresholdOutOfRangeIsRejected() throws {
        var config = configuration(items: [])
        var rule = try ColorRule(threshold: 0.8, color: .red)
        rule.threshold = 1.2
        config.colorRules["cpu"] = [rule]

        let errors = config.validationErrors(against: registry())

        XCTAssertEqual(errors, [.colorRuleThresholdOutOfRange(metricID: "cpu", threshold: 1.2)])
    }

    func testColorRulesWithinRangePass() throws {
        var config = configuration(items: [])
        config.colorRules["cpu"] = [try ColorRule(threshold: 0.8, color: .red)]

        XCTAssertEqual(config.validationErrors(against: registry()), [])
    }

    func testManagerRejectsInvalidConfiguration() throws {
        let registry = MetricRegistry()
        registry.register(FakeMetric(id: "cpu", supportedStyles: [.iconAndText]))
        let manager = PlaceholderManager(
            registry: registry,
            localization: localizationService(language: .english),
            onOpenPreferences: {}
        )
        let config = configuration(items: [try CarouselItem(metricID: "gpu", style: .text)])

        XCTAssertThrowsError(try manager.apply(config))
    }
}
