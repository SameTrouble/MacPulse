@testable import MacPulse
import XCTest

final class ColorBandTests: XCTestCase {
    func testAcceptsUpperBoundAtBounds() throws {
        XCTAssertEqual(try ColorBand(upperBound: 0, color: .green).upperBound, 0)
        XCTAssertEqual(try ColorBand(upperBound: 1, color: .green).upperBound, 1)
    }

    func testRejectsUpperBoundBelowZero() {
        XCTAssertThrowsError(try ColorBand(upperBound: -0.01, color: .green))
    }

    func testRejectsUpperBoundAboveOne() {
        XCTAssertThrowsError(try ColorBand(upperBound: 1.01, color: .green))
    }

    func testCodableRoundTrip() throws {
        let band = try ColorBand(upperBound: 0.8, color: .red)

        let data = try JSONEncoder().encode(band)
        let decoded = try JSONDecoder().decode(ColorBand.self, from: data)

        XCTAssertEqual(decoded, band)
    }

    func testDecodingRejectsOutOfRangeUpperBound() {
        let json = #"{"upperBound": 1.5, "color": "red"}"#

        XCTAssertThrowsError(try JSONDecoder().decode(ColorBand.self, from: Data(json.utf8)))
    }

    func testPaletteColorAllCasesRoundTrip() throws {
        for color in PaletteColor.allCases {
            let data = try JSONEncoder().encode(color)
            let decoded = try JSONDecoder().decode(PaletteColor.self, from: data)
            XCTAssertEqual(decoded, color)
        }
    }

    func testPaletteIncludesWhite() {
        XCTAssertTrue(PaletteColor.allCases.contains(.white))
    }
}
