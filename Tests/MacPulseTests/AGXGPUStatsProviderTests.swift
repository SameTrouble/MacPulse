@testable import MacPulse
import XCTest

final class AGXGPUStatsProviderTests: XCTestCase {
    func testReturnsUtilizationWithinValidRange() throws {
        try XCTSkipUnless(AGXGPUStatsProvider.isSupported, "requires Apple Silicon GPU")

        let stats = try currentStatsOrSkip()

        XCTAssertGreaterThanOrEqual(stats.deviceUtilizationPercent, 0)
        XCTAssertLessThanOrEqual(stats.deviceUtilizationPercent, 100)
    }

    private func currentStatsOrSkip() throws -> GPUStats {
        do {
            return try AGXGPUStatsProvider().currentStats()
        } catch GPUSamplingError.utilizationUnavailable {
            throw XCTSkip("GPU utilization not exposed on this host")
        }
    }
}
