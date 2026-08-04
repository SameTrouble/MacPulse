@testable import MacPulse
import XCTest

final class MemoryMetricTests: XCTestCase {
    private func metric(stats: MemoryStats) -> MemoryMetric {
        MemoryMetric(sampler: MemorySampler(provider: FakeMemoryStatsProvider(result: .success(stats))))
    }

    func testMetadata() {
        let metric = metric(stats: .fixture())

        XCTAssertEqual(metric.id, "memory")
        XCTAssertEqual(metric.displayNameKey, .metricMemoryName)
        XCTAssertEqual(metric.supportedStyles, [.iconAndText, .text, .progressBar])
    }

    func testSampleIsNilBeforeFirstRefresh() {
        XCTAssertNil(metric(stats: .fixture()).currentSample())
    }

    func testSampleShowsUsedGigabytesAndFraction() {
        let metric = metric(stats: .fixture())
        metric.refresh()

        let sample = metric.currentSample()
        XCTAssertEqual(sample?.text, MemoryUsageDisplay.gigabytes(300 * 4096))
        XCTAssertEqual(sample?.fraction ?? 0, 300.0 / 810.0, accuracy: 0.0001)
    }

    func testFailedRefreshClearsSample() {
        let provider = FakeMemoryStatsProvider(result: .success(.fixture()))
        let metric = MemoryMetric(sampler: MemorySampler(provider: provider))
        metric.refresh()

        provider.result = .failure(SamplingTestError())
        metric.refresh()

        XCTAssertNil(metric.currentSample())
    }

    func testMenuLinesShowUsedAndTotal() {
        let metric = metric(stats: .fixture())
        metric.refresh()

        let used = MemoryUsageDisplay.gigabytes(300 * 4096)
        let total = MemoryUsageDisplay.gigabytes(810 * 4096)
        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["已用：\(used)", "总量：\(total)"]
        )
        XCTAssertEqual(
            metric.menuLines(localizedBy: localizationService(language: .english)),
            ["Used: \(used)", "Total: \(total)"]
        )
    }

    func testMenuLinesShowDashesWithoutSample() {
        XCTAssertEqual(
            metric(stats: .fixture()).menuLines(localizedBy: localizationService(language: .zhHans)),
            ["已用：--", "总量：--"]
        )
        XCTAssertEqual(
            metric(stats: .fixture()).menuLines(localizedBy: localizationService(language: .english)),
            ["Used: --", "Total: --"]
        )
    }

    func testWidestDisplayTextIsWideGigabyteValue() {
        let metric = metric(stats: .fixture())

        XCTAssertEqual(metric.widestDisplayText(), "999.9 GB")
        XCTAssertEqual(metric.widestDisplayText(), MemoryUsageDisplay.widestText)
    }
}
