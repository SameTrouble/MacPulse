@testable import MacPulse
import XCTest

final class HostProcessorInfoProviderTests: XCTestCase {
    func testReturnsTickPerProcessor() throws {
        let ticks = try HostProcessorInfoProvider().currentTicks()
        let expected = ProcessInfo.processInfo.processorCount

        XCTAssertFalse(ticks.isEmpty)
        XCTAssertEqual(ticks.count, expected)
    }
}
