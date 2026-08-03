import Foundation
@testable import MacPulse
import XCTest
final class CPUUsageDisplayTests: XCTestCase {
    func testNilUsageShowsDashes() {
        XCTAssertEqual(CPUUsageDisplay.buttonTitle(for: nil), "--")
    }

    func testUsageShowsRoundedPercent() {
        let usage = CPUUsage(overall: 0.374, perCore: [])
        XCTAssertEqual(CPUUsageDisplay.buttonTitle(for: usage), "37%")
    }

    func testFullUsageShows100Percent() {
        let usage = CPUUsage(overall: 1.0, perCore: [])
        XCTAssertEqual(CPUUsageDisplay.buttonTitle(for: usage), "100%")
    }
}
