@testable import MacPulse
import XCTest

final class TemperatureMetricTests: XCTestCase {
    private func metric(cpu: Double, gpu: Double?) -> TemperatureMetric {
        let usage = TemperatureUsage(cpuCelsius: cpu, gpuCelsius: gpu)
        return TemperatureMetric(sampler: TemperatureSampler(provider: FakeTemperatureProvider(result: .success(usage))))
    }

    func testMetadata() {
        let metric = metric(cpu: 42, gpu: 40)

        XCTAssertEqual(metric.id, "temperature")
        XCTAssertEqual(metric.displayNameKey, .metricTemperatureName)
        XCTAssertEqual(metric.supportedStyles, [.iconAndText, .text])
    }

    func testDefaultSamplingIntervalIsFiveSeconds() {
        XCTAssertEqual(metric(cpu: 42, gpu: nil).defaultSamplingInterval, 5)
    }

    func testSampleIsNilBeforeFirstRefresh() {
        XCTAssertNil(metric(cpu: 42, gpu: nil).currentSample())
    }

    func testSampleShowsCelsius() {
        let metric = metric(cpu: 42.4, gpu: 40)
        metric.refresh()

        XCTAssertEqual(metric.currentSample()?.text, "42°")
        XCTAssertNil(metric.currentSample()?.fraction)
    }

    func testFailedRefreshClearsSample() {
        let provider = FakeTemperatureProvider(result: .success(TemperatureUsage(cpuCelsius: 42, gpuCelsius: 40)))
        let metric = TemperatureMetric(sampler: TemperatureSampler(provider: provider))
        metric.refresh()

        provider.result = .failure(SamplingTestError())
        metric.refresh()

        XCTAssertNil(metric.currentSample())
    }

    func testMenuLinesShowCpuAndGpu() {
        let metric = metric(cpu: 42, gpu: 40)
        metric.refresh()

        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["CPU：42°", "GPU：40°"]
        )
        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .english)),
            ["CPU: 42°", "GPU: 40°"]
        )
    }

    func testMenuLinesShowDashesForMissingGpu() {
        let metric = metric(cpu: 42, gpu: nil)
        metric.refresh()

        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["CPU：42°", "GPU：--"]
        )
        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .english)),
            ["CPU: 42°", "GPU: --"]
        )
    }

    func testMenuLinesShowDashesWithoutSample() {
        XCTAssertEqual(
            metric(cpu: 42, gpu: nil).menuLines(localizedBy: localizationService(language: .zhHans)),
            ["CPU：--", "GPU：--"]
        )
        XCTAssertEqual(
            metric(cpu: 42, gpu: nil).menuLines(localizedBy: localizationService(language: .english)),
            ["CPU: --", "GPU: --"]
        )
    }
}
