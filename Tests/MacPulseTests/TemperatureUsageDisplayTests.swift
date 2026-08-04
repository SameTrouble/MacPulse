@testable import MacPulse
import XCTest

final class TemperatureUsageDisplayTests: XCTestCase {
    func testCelsiusFormatsWholeDegrees() {
        XCTAssertEqual(TemperatureUsageDisplay.celsius(0), "0°")
        XCTAssertEqual(TemperatureUsageDisplay.celsius(36.5), "37°")
        XCTAssertEqual(TemperatureUsageDisplay.celsius(42.4), "42°")
        XCTAssertEqual(TemperatureUsageDisplay.celsius(42.6), "43°")
        XCTAssertEqual(TemperatureUsageDisplay.celsius(100), "100°")
    }

    func testFractionIsCelsiusOverOneHundredClamped() {
        XCTAssertEqual(TemperatureUsageDisplay.fraction(celsius: 0), 0)
        XCTAssertEqual(TemperatureUsageDisplay.fraction(celsius: 45), 0.45, accuracy: 0.0001)
        XCTAssertEqual(TemperatureUsageDisplay.fraction(celsius: 100), 1)
        XCTAssertEqual(TemperatureUsageDisplay.fraction(celsius: 150), 1)
        XCTAssertEqual(TemperatureUsageDisplay.fraction(celsius: -10), 0)
    }
}
