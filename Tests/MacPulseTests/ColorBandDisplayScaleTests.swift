@testable import MacPulse
import XCTest

final class ColorBandDisplayScaleTests: XCTestCase {
    func testCPUAndGPUTemperatureUseCelsius() {
        XCTAssertEqual(ColorBandDisplayScale.forMetricID(CPUTemperatureMetric.metricID), .celsius)
        XCTAssertEqual(ColorBandDisplayScale.forMetricID(GPUTemperatureMetric.metricID), .celsius)
    }

    func testNonTemperatureMetricsUsePercent() {
        XCTAssertEqual(ColorBandDisplayScale.forMetricID(CPUMetric.metricID), .percent)
        XCTAssertEqual(ColorBandDisplayScale.forMetricID(MemoryMetric.metricID), .percent)
        XCTAssertEqual(ColorBandDisplayScale.forMetricID(GPUMetric.metricID), .percent)
        XCTAssertEqual(ColorBandDisplayScale.forMetricID("unknown"), .percent)
    }

    func testPercentRangeLabelUsesPercentSign() {
        XCTAssertEqual(ColorBandDisplayScale.percent.rangeLabel(lower: 0.4, upper: 0.7), "40–70%")
        XCTAssertEqual(ColorBandDisplayScale.percent.rangeLabel(lower: 0, upper: 0.5), "0–50%")
    }

    func testCelsiusRangeLabelUsesDegreeC() {
        XCTAssertEqual(ColorBandDisplayScale.celsius.rangeLabel(lower: 0.4, upper: 0.7), "40–70°C")
        XCTAssertEqual(ColorBandDisplayScale.celsius.rangeLabel(lower: 0, upper: 1), "0–100°C")
    }

    func testFullScaleLabels() {
        XCTAssertEqual(ColorBandDisplayScale.percent.fullScaleLabel, "100%")
        XCTAssertEqual(ColorBandDisplayScale.celsius.fullScaleLabel, "100°C")
    }
}
