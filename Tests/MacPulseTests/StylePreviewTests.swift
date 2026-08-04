@testable import MacPulse
import XCTest

final class StylePreviewTests: XCTestCase {
    func testMemorySampleTextUsesGigabyteFormat() {
        XCTAssertEqual(StylePreview.sampleText(forMetricID: MemoryMetric.metricID), "12.3 GB")
    }

    func testCPUSampleTextUsesPercentFormat() {
        XCTAssertEqual(StylePreview.sampleText(forMetricID: CPUMetric.metricID), "73%")
    }

    func testGPUSampleTextUsesPercentFormat() {
        XCTAssertEqual(StylePreview.sampleText(forMetricID: GPUMetric.metricID), "73%")
    }

    func testTemperatureSampleTextUsesDegreesFormat() {
        XCTAssertEqual(StylePreview.sampleText(forMetricID: TemperatureMetric.metricID), "45°")
    }

    func testUnknownMetricSampleTextFallsBackToPercent() {
        XCTAssertEqual(StylePreview.sampleText(forMetricID: "unknown"), "73%")
    }

    func testProgressBarPreviewUsesSampleFraction() {
        let image = StylePreview.image(
            for: .progressBar,
            symbolName: "cpu.fill",
            metricID: CPUMetric.metricID
        )
        let expected = ProgressBarImage.makeImage(fraction: StylePreview.sampleFraction)
        XCTAssertEqual(StylePreview.sampleFraction, 0.73)
        XCTAssertEqual(image.size, expected.size)
        XCTAssertEqual(image.tiffRepresentation, expected.tiffRepresentation)
    }

    func testIconAndTextPreviewDiffersBetweenCPUAndMemory() {
        let cpu = StylePreview.image(
            for: .iconAndText,
            symbolName: "cpu.fill",
            metricID: CPUMetric.metricID
        )
        let memory = StylePreview.image(
            for: .iconAndText,
            symbolName: "memorychip",
            metricID: MemoryMetric.metricID
        )
        XCTAssertNotEqual(cpu.tiffRepresentation, memory.tiffRepresentation)
    }

    func testTextPreviewDiffersBetweenCPUAndMemory() {
        let cpu = StylePreview.image(
            for: .text,
            symbolName: "cpu.fill",
            metricID: CPUMetric.metricID
        )
        let memory = StylePreview.image(
            for: .text,
            symbolName: "memorychip",
            metricID: MemoryMetric.metricID
        )
        XCTAssertNotEqual(cpu.tiffRepresentation, memory.tiffRepresentation)
    }
}
