@testable import MacPulse
import XCTest

final class AppConfigurationDefaultsTests: XCTestCase {
    func testDefaultsContainExactlyOnePlaceholder() {
        XCTAssertEqual(AppConfiguration.defaults.placeholders.count, 1)
    }

    func testDefaultPlaceholderHasTwoCPUItems() {
        let placeholder = AppConfiguration.defaults.placeholders[0]

        XCTAssertEqual(placeholder.items.count, 2)
        XCTAssertTrue(placeholder.items.allSatisfy { $0.metricID == CPUMetric.metricID })
    }

    func testDefaultItemsUseIconAndTextThenTextStyles() {
        let items = AppConfiguration.defaults.placeholders[0].items

        XCTAssertEqual(items.map(\.style), [.iconAndText, .text])
    }

    func testDefaultItemsHaveThreeSecondDurations() {
        let items = AppConfiguration.defaults.placeholders[0].items

        XCTAssertEqual(items.map(\.duration), [3, 3])
        XCTAssertTrue(items.allSatisfy { CarouselItem.durationRange.contains($0.duration) })
    }

    func testDefaultsPassValidationAgainstRealRegistry() {
        let registry = MetricRegistry()
        registry.register(CPUMetric())

        XCTAssertEqual(AppConfiguration.defaults.validationErrors(against: registry), [])
    }

    func testDefaultPlaceholderMenuShowsCPU() {
        let placeholder = AppConfiguration.defaults.placeholders[0]

        XCTAssertEqual(placeholder.menuMetricIDs, [CPUMetric.metricID])
    }
}
