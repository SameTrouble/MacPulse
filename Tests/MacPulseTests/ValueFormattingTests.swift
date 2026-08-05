import Foundation
@testable import MacPulse
import XCTest

final class ValueFormattingTests: XCTestCase {
    private static let gib = UInt64(1024 * 1024 * 1024)

    func testPercentShowsRoundedWholePercent() {
        XCTAssertEqual(ValueFormatting.percent(0.374), "37%")
        XCTAssertEqual(ValueFormatting.percent(1.0), "100%")
    }

    func testGigabytesFormatsWithOneDecimal() {
        XCTAssertEqual(ValueFormatting.gigabytes(2 * Self.gib), "2.0 GB")
        XCTAssertEqual(ValueFormatting.gigabytes(Self.gib / 2), "0.5 GB")
    }

    func testGigabytesRoundsToOneDecimal() {
        XCTAssertEqual(ValueFormatting.gigabytes(11_382_851_994), "10.6 GB")
    }

    func testCelsiusFormatsWholeDegrees() {
        XCTAssertEqual(ValueFormatting.celsius(0), "0°")
        XCTAssertEqual(ValueFormatting.celsius(36.5), "37°")
        XCTAssertEqual(ValueFormatting.celsius(42.4), "42°")
        XCTAssertEqual(ValueFormatting.celsius(42.6), "43°")
        XCTAssertEqual(ValueFormatting.celsius(100), "100°")
    }

    func testFallbackTextIsDashes() {
        XCTAssertEqual(ValueFormatting.fallback, "--")
    }
}
