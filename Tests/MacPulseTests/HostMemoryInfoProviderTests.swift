@testable import MacPulse
import XCTest

final class HostMemoryInfoProviderTests: XCTestCase {
    func testReturnsPlausibleStats() throws {
        let stats = try HostMemoryInfoProvider().currentStats()

        XCTAssertGreaterThan(stats.pageSize, 0)
        XCTAssertGreaterThan(stats.totalBytes, 0)
    }
}
