@testable import MacPulse
import XCTest

final class GPUSamplerTests: XCTestCase {
    func testRefreshConvertsPercentToFraction() throws {
        let sampler = GPUSampler(provider: FakeGPUStatsProvider(result: .success(GPUStats(deviceUtilizationPercent: 45))))

        let usage = try sampler.refresh()

        XCTAssertEqual(usage.deviceUtilization, 0.45, accuracy: 0.0001)
    }

    func testRefreshClampsPercentAboveOneHundred() throws {
        let sampler = GPUSampler(provider: FakeGPUStatsProvider(result: .success(GPUStats(deviceUtilizationPercent: 150))))

        let usage = try sampler.refresh()

        XCTAssertEqual(usage.deviceUtilization, 1.0, accuracy: 0.0001)
    }

    func testRefreshClampsNegativePercent() throws {
        let sampler = GPUSampler(provider: FakeGPUStatsProvider(result: .success(GPUStats(deviceUtilizationPercent: -3))))

        let usage = try sampler.refresh()

        XCTAssertEqual(usage.deviceUtilization, 0.0, accuracy: 0.0001)
    }

    func testRefreshPropagatesProviderFailure() {
        let sampler = GPUSampler(provider: FakeGPUStatsProvider(result: .failure(SamplingTestError())))

        XCTAssertThrowsError(try sampler.refresh())
    }
}
