@testable import MacPulse
import XCTest

final class StatusBarRendererTests: XCTestCase {
    func testAttributedTitleWithoutColorIsNil() {
        XCTAssertNil(StatusBarRenderer.attributedTitle(text: "42%", color: nil))
    }

    func testAttributedTitleWithColorKeepsText() {
        let title = StatusBarRenderer.attributedTitle(text: "42%", color: .systemRed)

        XCTAssertEqual(title?.string, "42%")
    }

    func testAttributedTitleWithColorHasForegroundColor() {
        let title = StatusBarRenderer.attributedTitle(text: "42%", color: .systemRed)

        let color = title?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor
        XCTAssertEqual(color, .systemRed)
    }

    func testAttributedTitleWithoutColorHasNoForegroundAttribute() {
        XCTAssertNil(StatusBarRenderer.attributedTitle(text: "42%", color: nil))
    }

    func testIconImageWithoutColorIsTemplate() {
        let image = StatusBarRenderer.iconImage(symbolName: "cpu.fill", accessibilityDescription: nil, color: nil)

        XCTAssertNotNil(image)
        XCTAssertTrue(image?.isTemplate ?? false)
    }

    func testIconImageWithColorIsNotTemplate() {
        let image = StatusBarRenderer.iconImage(symbolName: "cpu.fill", accessibilityDescription: nil, color: .systemRed)

        XCTAssertNotNil(image)
        XCTAssertFalse(image?.isTemplate ?? true)
    }
}
