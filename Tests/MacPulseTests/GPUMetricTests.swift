@testable import MacPulse
import XCTest

final class GPUMetricTests: XCTestCase {
    func testMetadata() {
        let metric = GPUMetric(provider: FakeGPUUtilizationProvider(result: .failure(SamplingTestError())))

        XCTAssertEqual(metric.id, "gpu")
        XCTAssertEqual(metric.displayName, "GPU")
        XCTAssertEqual(metric.supportedStyles, [.iconAndText, .text])
        XCTAssertEqual(metric.defaultSamplingInterval, 2)
    }

    func testSampleIsNilBeforeFirstUsableRefresh() {
        let metric = GPUMetric(provider: FakeGPUUtilizationProvider(result: .failure(SamplingTestError())))

        metric.refresh()

        XCTAssertNil(metric.currentSample())
    }

    func testSampleReflectsLatestUtilization() {
        let provider = FakeGPUUtilizationProvider(result: .success(GPUUtilization(device: 0.37)))
        let metric = GPUMetric(provider: provider)
        metric.refresh()

        provider.result = .success(GPUUtilization(device: 0.61))
        metric.refresh()

        let sample = metric.currentSample()
        XCTAssertEqual(sample?.text, "61%")
        XCTAssertEqual(sample?.fraction ?? 0, 0.61, accuracy: 0.0001)
    }

    func testFailedRefreshClearsSample() {
        let provider = FakeGPUUtilizationProvider(result: .success(GPUUtilization(device: 0.61)))
        let metric = GPUMetric(provider: provider)
        metric.refresh()

        provider.result = .failure(SamplingTestError())
        metric.refresh()

        XCTAssertNil(metric.currentSample())
    }

    func testMenuLinesShowUtilization() {
        let metric = GPUMetric(provider: FakeGPUUtilizationProvider(result: .success(GPUUtilization(device: 0.5))))
        metric.refresh()

        XCTAssertEqual(metric.menuLines(), ["GPU 利用率：50%"])
    }

    func testMenuLinesShowDashesWithoutSample() {
        let metric = GPUMetric(provider: FakeGPUUtilizationProvider(result: .failure(SamplingTestError())))

        XCTAssertEqual(metric.menuLines(), ["GPU 利用率：--"])
    }
}
