@testable import MacPulse
import XCTest

final class MetricRegistryTests: XCTestCase {
    func testRegisteredMetricIsLookedUpById() {
        let registry = MetricRegistry()
        let metric = FakeMetric(id: "cpu")

        registry.register(metric)

        XCTAssertTrue(registry.metric(id: "cpu") === metric)
    }

    func testUnknownIdReturnsNil() {
        let registry = MetricRegistry()

        XCTAssertNil(registry.metric(id: "missing"))
    }

    func testDuplicateRegistrationReplacesPrevious() {
        let registry = MetricRegistry()
        registry.register(FakeMetric(id: "cpu", supportedStyles: [.text]))
        let replacement = FakeMetric(id: "cpu", supportedStyles: [.iconAndText])

        registry.register(replacement)

        XCTAssertTrue(registry.metric(id: "cpu") === replacement)
    }

    func testListsMetricsInRegistrationOrder() {
        let registry = MetricRegistry()
        registry.register(FakeMetric(id: "cpu"))
        registry.register(FakeMetric(id: "memory"))
        registry.register(FakeMetric(id: "cpu"))

        XCTAssertEqual(registry.metrics.map(\.id), ["cpu", "memory"])
    }
}
