@testable import MacPulse
import XCTest

final class MemoryUsageCalculatorTests: XCTestCase {
    func testTotalBytesComesFromPhysicalMemory() {
        let usage = MemoryUsageCalculator.usage(.fixture(totalBytes: 16 * 1024 * 1024 * 1024))
        XCTAssertEqual(usage.totalBytes, 16 * 1024 * 1024 * 1024)
    }

    func testUsedBytesCoverActiveWiredAndCompressedPages() {
        let usage = MemoryUsageCalculator.usage(.fixture(active: 100, wired: 200, compressor: 10))
        XCTAssertEqual(usage.usedBytes, 310 * 4096)
    }

    func testFractionIsUsedOverTotal() {
        let usage = MemoryUsageCalculator.usage(.fixture(active: 100, wired: 200, compressor: 10, totalBytes: 820 * 4096))
        XCTAssertEqual(usage.fraction, 310.0 / 820.0, accuracy: 0.0001)
    }

    func testFractionIsZeroWhenTotalIsZero() {
        let usage = MemoryUsageCalculator.usage(.fixture(active: 0, wired: 0, compressor: 0, totalBytes: 0))
        XCTAssertEqual(usage.usedBytes, 0)
        XCTAssertEqual(usage.totalBytes, 0)
        XCTAssertEqual(usage.fraction, 0)
    }
}
