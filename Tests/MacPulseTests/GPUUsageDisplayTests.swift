@testable import MacPulse
import XCTest

final class GPUUsageDisplayTests: XCTestCase {
    func testNilUsageShowsDashes() {
        XCTAssertEqual(GPUUsageDisplay.buttonTitle(for: nil), "--")
    }

    func testUsageShowsRoundedPercent() {
        let usage = GPUUsage(deviceUtilization: 0.374)
        XCTAssertEqual(GPUUsageDisplay.buttonTitle(for: usage), "37%")
    }

    func testFullUsageShows100Percent() {
        let usage = GPUUsage(deviceUtilization: 1.0)
        XCTAssertEqual(GPUUsageDisplay.buttonTitle(for: usage), "100%")
    }
}
