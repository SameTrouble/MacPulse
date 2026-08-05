import Foundation
@testable import MacPulse
import XCTest

private final class FakeUsageSampler: Sampling {
    var result: Result<String, Error>

    init(result: Result<String, Error>) {
        self.result = result
    }

    func refresh() throws -> String {
        try result.get()
    }
}

private final class FakeSampledMetric: SampledMetric<String, FakeUsageSampler> {
    override func makeSample(from usage: String) -> MetricSample? {
        MetricSample(text: usage, fraction: 1)
    }
}

final class SampledMetricTests: XCTestCase {
    private func metric(result: Result<String, Error>) -> (FakeSampledMetric, FakeUsageSampler) {
        let sampler = FakeUsageSampler(result: result)
        let metric = FakeSampledMetric(
            id: "fake",
            displayNameKey: .metricCPUName,
            symbolName: "cpu",
            supportedStyles: [.text],
            defaultSamplingInterval: 3,
            sampler: sampler
        )
        return (metric, sampler)
    }

    func testMetadataPassthrough() {
        let (metric, _) = metric(result: .success("x"))

        XCTAssertEqual(metric.id, "fake")
        XCTAssertEqual(metric.displayNameKey, .metricCPUName)
        XCTAssertEqual(metric.symbolName, "cpu")
        XCTAssertEqual(metric.supportedStyles, [.text])
        XCTAssertEqual(metric.defaultSamplingInterval, 3)
    }

    func testSampleIsNilBeforeFirstRefresh() {
        let (metric, _) = metric(result: .success("x"))

        XCTAssertNil(metric.currentSample())
    }

    func testRefreshPacksSampleThroughSubclass() {
        let (metric, _) = metric(result: .success("42%"))
        metric.refresh()

        let sample = metric.currentSample()
        XCTAssertEqual(sample?.text, "42%")
        XCTAssertEqual(sample?.fraction, 1)
    }

    func testFailedRefreshClearsSample() {
        let (metric, sampler) = metric(result: .success("42%"))
        metric.refresh()
        sampler.result = .failure(SamplingTestError())
        metric.refresh()

        XCTAssertNil(metric.currentSample())
    }
}
