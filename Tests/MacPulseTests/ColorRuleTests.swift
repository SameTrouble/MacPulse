@testable import MacPulse
import XCTest

final class ColorRuleTests: XCTestCase {
    func testAcceptsThresholdAtBounds() throws {
        XCTAssertEqual(try ColorRule(threshold: 0, color: .green).threshold, 0)
        XCTAssertEqual(try ColorRule(threshold: 1, color: .green).threshold, 1)
    }

    func testRejectsThresholdBelowZero() {
        XCTAssertThrowsError(try ColorRule(threshold: -0.01, color: .green))
    }

    func testRejectsThresholdAboveOne() {
        XCTAssertThrowsError(try ColorRule(threshold: 1.01, color: .green))
    }

    func testCodableRoundTrip() throws {
        let rule = try ColorRule(threshold: 0.8, color: .red)

        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(ColorRule.self, from: data)

        XCTAssertEqual(decoded, rule)
    }

    func testDecodingRejectsOutOfRangeThreshold() {
        let json = #"{"threshold": 1.5, "color": "red"}"#

        XCTAssertThrowsError(try JSONDecoder().decode(ColorRule.self, from: Data(json.utf8)))
    }

    func testPaletteColorAllCasesRoundTrip() throws {
        for color in PaletteColor.allCases {
            let data = try JSONEncoder().encode(color)
            let decoded = try JSONDecoder().decode(PaletteColor.self, from: data)
            XCTAssertEqual(decoded, color)
        }
    }

    func testPaletteOffersMultipleColors() {
        XCTAssertGreaterThan(PaletteColor.allCases.count, 3)
    }
}
