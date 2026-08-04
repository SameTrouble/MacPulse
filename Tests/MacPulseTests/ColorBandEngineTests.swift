@testable import MacPulse
import XCTest

final class ColorBandEngineTests: XCTestCase {
    private func band(upperBound: Double, color: PaletteColor) throws -> ColorBand {
        try ColorBand(upperBound: upperBound, color: color)
    }

    func testNilFractionReturnsNoMatch() throws {
        let bands = [try band(upperBound: 0.5, color: .orange)]

        XCTAssertNil(ColorBandEngine.matchingBand(fraction: nil, bands: bands))
    }

    func testEmptyBandsReturnNoMatch() {
        XCTAssertNil(ColorBandEngine.matchingBand(fraction: 0.9, bands: []))
    }

    func testAscendingBandsHitExpectedColors() throws {
        let bands = [
            try band(upperBound: 0.2, color: .white),
            try band(upperBound: 0.6, color: .yellow),
            try band(upperBound: 0.8, color: .orange),
            try band(upperBound: 1.0, color: .red)
        ]

        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.1, bands: bands)?.color, .white)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.5, bands: bands)?.color, .yellow)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.7, bands: bands)?.color, .orange)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.9, bands: bands)?.color, .red)
    }

    func testDescendingInputMatchesSameAsAscending() throws {
        let ascending = [
            try band(upperBound: 0.2, color: .white),
            try band(upperBound: 0.6, color: .yellow),
            try band(upperBound: 1.0, color: .red)
        ]
        let descending = [
            try band(upperBound: 1.0, color: .red),
            try band(upperBound: 0.6, color: .yellow),
            try band(upperBound: 0.2, color: .white)
        ]

        XCTAssertEqual(
            ColorBandEngine.matchingBand(fraction: 0.5, bands: ascending)?.color,
            ColorBandEngine.matchingBand(fraction: 0.5, bands: descending)?.color
        )
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.5, bands: descending)?.color, .yellow)
    }

    func testShuffledInputMatchesSameAsAscending() throws {
        let shuffled = [
            try band(upperBound: 0.6, color: .yellow),
            try band(upperBound: 1.0, color: .red),
            try band(upperBound: 0.2, color: .white)
        ]

        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.15, bands: shuffled)?.color, .white)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.6, bands: shuffled)?.color, .yellow)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.95, bands: shuffled)?.color, .red)
    }

    func testValueEqualToUpperBoundBelongsToThatBand() throws {
        let bands = [
            try band(upperBound: 0.2, color: .white),
            try band(upperBound: 0.6, color: .yellow),
            try band(upperBound: 1.0, color: .red)
        ]

        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.2, bands: bands)?.color, .white)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.6, bands: bands)?.color, .yellow)
    }

    func testZeroAndOneFractions() throws {
        let bands = [
            try band(upperBound: 0.5, color: .green),
            try band(upperBound: 1.0, color: .red)
        ]

        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0, bands: bands)?.color, .green)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 1, bands: bands)?.color, .red)
    }

    func testSingleBandCoversFullRange() throws {
        let bands = [try band(upperBound: 1.0, color: .blue)]

        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0, bands: bands)?.color, .blue)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 0.5, bands: bands)?.color, .blue)
        XCTAssertEqual(ColorBandEngine.matchingBand(fraction: 1, bands: bands)?.color, .blue)
    }
}
