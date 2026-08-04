@testable import MacPulse
import XCTest

final class ProgressBarImageTests: XCTestCase {
    func testNilFractionClampsToZero() {
        XCTAssertEqual(ProgressBarImage.clampedFraction(nil), 0)
    }

    func testNegativeFractionClampsToZero() {
        XCTAssertEqual(ProgressBarImage.clampedFraction(-0.5), 0)
    }

    func testFractionAboveOneClampsToOne() {
        XCTAssertEqual(ProgressBarImage.clampedFraction(1.5), 1)
    }

    func testFractionInRangeIsPreserved() {
        XCTAssertEqual(ProgressBarImage.clampedFraction(0.374), 0.374)
    }

    func testZeroFractionHasNoFill() {
        XCTAssertEqual(ProgressBarImage.fillWidth(for: nil), 0)
        XCTAssertEqual(ProgressBarImage.fillWidth(for: 0), 0)
    }

    func testFullFractionFillsFullWidth() {
        XCTAssertEqual(ProgressBarImage.fillWidth(for: 1), ProgressBarImage.size.width)
    }

    func testHalfFractionFillsHalfWidth() {
        XCTAssertEqual(ProgressBarImage.fillWidth(for: 0.5), ProgressBarImage.size.width / 2)
    }

    func testPositiveFractionKeepsMinimumVisibleFill() {
        XCTAssertGreaterThanOrEqual(ProgressBarImage.fillWidth(for: 0.001), 1)
    }

    func testImageHasStableSizeAcrossFractions() {
        let empty = ProgressBarImage.makeImage(fraction: nil)
        let partial = ProgressBarImage.makeImage(fraction: 0.374)
        let full = ProgressBarImage.makeImage(fraction: 1)

        XCTAssertEqual(empty.size, ProgressBarImage.size)
        XCTAssertEqual(partial.size, ProgressBarImage.size)
        XCTAssertEqual(full.size, ProgressBarImage.size)
    }

    func testSizeIsSlimLeanBar() {
        XCTAssertEqual(ProgressBarImage.size, NSSize(width: 28, height: 6))
    }

    func testImageIsTemplateSoItAdaptsToMenuBarAppearance() {
        XCTAssertTrue(ProgressBarImage.makeImage(fraction: 0.5).isTemplate)
    }
}
