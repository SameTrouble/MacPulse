import XCTest

final class ScaffoldTests: XCTestCase {
    func testInfoMarksAppAsUIElement() {
        let value = Bundle.main.infoDictionary?["LSUIElement"]
        XCTAssertEqual(value as? Bool, true)
    }
}
