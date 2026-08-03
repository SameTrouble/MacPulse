@testable import MacPulse
import XCTest

final class SamplingIntervalTests: XCTestCase {
    func testSamplingIntervalFallsBackToMetricDefault() {
        let configuration = AppConfiguration(placeholders: [])
        let metric = FakeMetric(id: "cpu", defaultSamplingInterval: 2)

        XCTAssertEqual(configuration.samplingInterval(for: metric), 2)
    }

    func testSamplingIntervalOverrideWins() {
        var configuration = AppConfiguration(placeholders: [])
        configuration.samplingIntervals["cpu"] = 7
        let metric = FakeMetric(id: "cpu", defaultSamplingInterval: 2)

        XCTAssertEqual(configuration.samplingInterval(for: metric), 7)
    }

    func testCPUMetricDefaultSamplingIntervalIsTwoSeconds() {
        XCTAssertEqual(CPUMetric().defaultSamplingInterval, 2)
    }
}
