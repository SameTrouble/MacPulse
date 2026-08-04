@testable import MacPulse
import XCTest

final class CPUMetricTests: XCTestCase {
    func testMetadata() {
        let metric = CPUMetric(sampler: CPUUsageSampler(provider: FakeTickProvider(result: .success([]))))

        XCTAssertEqual(metric.id, "cpu")
        XCTAssertEqual(metric.displayNameKey, .metricCPUName)
        XCTAssertEqual(metric.supportedStyles, [.iconAndText, .text, .progressBar])
    }

    func testSampleIsNilBeforeFirstUsableRefresh() {
        let provider = FakeTickProvider(result: .success([CPUTick(user: 10, system: 0, idle: 90, nice: 0)]))
        let metric = CPUMetric(sampler: CPUUsageSampler(provider: provider))

        metric.refresh()

        XCTAssertNil(metric.currentSample())
    }

    func testSampleReflectsLatestUsage() {
        let provider = FakeTickProvider(result: .success([CPUTick(user: 0, system: 0, idle: 100, nice: 0)]))
        let metric = CPUMetric(sampler: CPUUsageSampler(provider: provider))
        metric.refresh()

        provider.result = .success([CPUTick(user: 50, system: 0, idle: 150, nice: 0)])
        metric.refresh()

        let sample = metric.currentSample()
        XCTAssertEqual(sample?.text, "50%")
        XCTAssertEqual(sample?.fraction ?? 0, 0.5, accuracy: 0.0001)
    }

    func testFailedRefreshClearsSample() {
        let provider = FakeTickProvider(result: .success([CPUTick(user: 0, system: 0, idle: 100, nice: 0)]))
        let metric = CPUMetric(sampler: CPUUsageSampler(provider: provider))
        metric.refresh()
        provider.result = .success([CPUTick(user: 50, system: 0, idle: 150, nice: 0)])
        metric.refresh()

        provider.result = .failure(SamplingTestError())
        metric.refresh()

        XCTAssertNil(metric.currentSample())
    }

    func testMenuLinesShowOverallAndPerCore() {
        let provider = FakeTickProvider(result: .success([
            CPUTick(user: 0, system: 0, idle: 0, nice: 0),
            CPUTick(user: 0, system: 0, idle: 0, nice: 0)
        ]))
        let metric = CPUMetric(sampler: CPUUsageSampler(provider: provider))
        metric.refresh()

        provider.result = .success([
            CPUTick(user: 100, system: 0, idle: 100, nice: 0),
            CPUTick(user: 50, system: 0, idle: 150, nice: 0)
        ])
        metric.refresh()

        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["总体 CPU：38%", "核心 1：50%", "核心 2：25%"]
        )
        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .english)),
            ["Overall CPU: 38%", "Core 1: 50%", "Core 2: 25%"]
        )
    }

    func testMenuLinesShowDashesWithoutSample() {
        let metric = CPUMetric(sampler: CPUUsageSampler(provider: FakeTickProvider(result: .success([]))))

        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["总体 CPU：--"]
        )
        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .english)),
            ["Overall CPU: --"]
        )
    }

    func testWidestDisplayTextIsThreeDigitPercent() {
        let metric = CPUMetric(sampler: CPUUsageSampler(provider: FakeTickProvider(result: .success([]))))

        XCTAssertEqual(metric.widestDisplayText(), "100%")
        XCTAssertEqual(metric.widestDisplayText(), CPUUsageDisplay.widestText)
    }
}
