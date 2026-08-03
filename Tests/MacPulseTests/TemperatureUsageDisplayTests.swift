@testable import MacPulse
import XCTest

final class TemperatureUsageDisplayTests: XCTestCase {
    func testButtonTitleShowsWholeDegrees() {
        let usage = TemperatureUsage(cpuCelsius: 42.4, gpuCelsius: 40.2)

        XCTAssertEqual(TemperatureUsageDisplay.buttonTitle(for: usage), "42°")
    }

    func testButtonTitleRoundsUp() {
        let usage = TemperatureUsage(cpuCelsius: 42.6, gpuCelsius: nil)

        XCTAssertEqual(TemperatureUsageDisplay.buttonTitle(for: usage), "43°")
    }

    func testCelsiusFormatsWholeDegrees() {
        XCTAssertEqual(TemperatureUsageDisplay.celsius(0), "0°")
        XCTAssertEqual(TemperatureUsageDisplay.celsius(36.5), "37°")
        XCTAssertEqual(TemperatureUsageDisplay.celsius(100), "100°")
    }
}
