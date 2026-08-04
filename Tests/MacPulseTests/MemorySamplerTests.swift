@testable import MacPulse
import XCTest

final class MemorySamplerTests: XCTestCase {
    func testRefreshReturnsComputedUsage() throws {
        let sampler = MemorySampler(provider: FakeMemoryStatsProvider(result: .success(.fixture())))

        let usage = try sampler.refresh()

        XCTAssertEqual(usage.usedBytes, 300 * 4096)
        XCTAssertEqual(usage.totalBytes, 810 * 4096)
    }

    func testRefreshPropagatesProviderFailure() {
        let sampler = MemorySampler(provider: FakeMemoryStatsProvider(result: .failure(SamplingTestError())))

        XCTAssertThrowsError(try sampler.refresh())
    }
}
