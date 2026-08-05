@testable import MacPulse
import XCTest

final class GPUMetricTests: XCTestCase {
    private func metric(utilization: Int) -> GPUMetric {
        GPUMetric(sampler: GPUSampler(provider: FakeGPUStatsProvider(result: .success(GPUStats(deviceUtilizationPercent: utilization)))))
    }

    func testMetadata() {
        let metric = metric(utilization: 0)

        XCTAssertEqual(metric.id, "gpu")
        XCTAssertEqual(metric.displayNameKey, .metricGPUName)
        XCTAssertEqual(metric.supportedStyles, [.iconAndText, .text, .progressBar])
    }

    func testSampleIsNilBeforeFirstRefresh() {
        XCTAssertNil(metric(utilization: 0).currentSample())
    }

    func testSampleShowsPercentAndFraction() {
        let metric = metric(utilization: 45)
        metric.refresh()

        let sample = metric.currentSample()
        XCTAssertEqual(sample?.text, "45%")
        XCTAssertEqual(sample?.fraction ?? 0, 0.45, accuracy: 0.0001)
    }

    func testFailedRefreshClearsSample() {
        let provider = FakeGPUStatsProvider(result: .success(GPUStats(deviceUtilizationPercent: 45)))
        let metric = GPUMetric(sampler: GPUSampler(provider: provider))
        metric.refresh()

        provider.result = .failure(SamplingTestError())
        metric.refresh()

        XCTAssertNil(metric.currentSample())
    }

    func testMenuLinesShowUtilization() {
        let metric = metric(utilization: 45)
        metric.refresh()

        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["GPU 利用率：45%"]
        )
        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .english)),
            ["GPU utilization: 45%"]
        )
    }

    func testMenuLinesShowDashesWithoutSample() {
        XCTAssertEqual(
            metric(utilization: 0).menuLines(localizedBy: localizationService(language: .zhHans)),
            ["GPU 利用率：--"]
        )
        XCTAssertEqual(
            metric(utilization: 0).menuLines(localizedBy: localizationService(language: .english)),
            ["GPU utilization: --"]
        )
    }

    func testWidestDisplayTextIsThreeDigitPercent() {
        let metric = metric(utilization: 0)

        XCTAssertEqual(metric.widestDisplayText(), "100%")
        XCTAssertEqual(metric.widestDisplayText(), ValueFormatting.widestPercent)
    }
}
