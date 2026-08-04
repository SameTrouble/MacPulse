import AppKit
@testable import MacPulse
import XCTest

final class MenuRowFactoryTests: XCTestCase {
    func testTitleRowIsEnabled() {
        XCTAssertTrue(MenuRowFactory.title("CPU 温度").isEnabled)
    }

    func testTitleRowHasNoAction() {
        let item = MenuRowFactory.title("CPU 温度")
        XCTAssertNil(item.action)
        XCTAssertNil(item.target)
    }

    func testTitleRowIsBold() {
        let item = MenuRowFactory.title("CPU 温度")
        let attributed = try? XCTUnwrap(item.attributedTitle)
        let font = attributed?.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
        XCTAssertEqual(font, NSFont.boldSystemFont(ofSize: NSFont.systemFontSize))
    }

    func testDataRowIsEnabled() {
        XCTAssertTrue(MenuRowFactory.data("CPU 使用率 23%").isEnabled)
    }

    func testDataRowHasNoAction() {
        let item = MenuRowFactory.data("CPU 使用率 23%")
        XCTAssertNil(item.action)
        XCTAssertNil(item.target)
    }

    func testDataRowKeepsPlainTitle() {
        let item = MenuRowFactory.data("CPU 使用率 23%")
        XCTAssertEqual(item.title, "CPU 使用率 23%")
        XCTAssertNil(item.attributedTitle)
    }
}
