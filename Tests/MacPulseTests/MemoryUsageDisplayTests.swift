@testable import MacPulse
import XCTest

final class MemoryUsageDisplayTests: XCTestCase {
    private static let gib = UInt64(1024 * 1024 * 1024)

    func testButtonTitleShowsUsedGigabytes() {
        let usage = MemoryUsage(usedBytes: 9 * Self.gib, totalBytes: 16 * Self.gib)
        XCTAssertEqual(MemoryUsageDisplay.buttonTitle(for: usage), "9.0 GB")
    }

    func testButtonTitleRoundsToOneDecimal() {
        let usage = MemoryUsage(usedBytes: 11_382_851_994, totalBytes: 16 * Self.gib)
        XCTAssertEqual(MemoryUsageDisplay.buttonTitle(for: usage), "10.6 GB")
    }

    func testButtonTitleShowsDashesForNil() {
        XCTAssertEqual(MemoryUsageDisplay.buttonTitle(for: nil), "--")
    }

    func testGigabytesFormatsWithDecimal() {
        XCTAssertEqual(MemoryUsageDisplay.gigabytes(2 * Self.gib), "2.0 GB")
        XCTAssertEqual(MemoryUsageDisplay.gigabytes(Self.gib / 2), "0.5 GB")
    }
}
