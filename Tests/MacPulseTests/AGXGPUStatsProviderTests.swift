@testable import MacPulse
import XCTest

final class AGXGPUStatsProviderTests: XCTestCase {
    func testReturnsUtilizationWithinValidRange() throws {
        try XCTSkipUnless(AGXGPUStatsProvider.isSupported, "requires Apple Silicon GPU")

        do {
            let stats = try AGXGPUStatsProvider().currentStats()

            XCTAssertGreaterThanOrEqual(stats.deviceUtilizationPercent, 0)
            XCTAssertLessThanOrEqual(stats.deviceUtilizationPercent, 100)
        } catch GPUSamplingError.utilizationUnavailable {
            throw XCTSkip("GPU utilization not exposed on this host")
        }
    }
}
