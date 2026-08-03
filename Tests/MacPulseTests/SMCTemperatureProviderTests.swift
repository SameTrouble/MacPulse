@testable import MacPulse
import XCTest

final class SMCTemperatureProviderTests: XCTestCase {
    func testReadsCpuTemperatureInPlausibleRange() throws {
        try XCTSkipUnless(SMCTemperatureProvider.isSupported, "requires Apple Silicon SMC")

        let usage = try readCurrentStats()

        XCTAssertGreaterThan(usage.cpuCelsius, 0)
        XCTAssertLessThan(usage.cpuCelsius, 130)
    }

    func testReadsGpuTemperatureInPlausibleRangeWhenAvailable() throws {
        try XCTSkipUnless(SMCTemperatureProvider.isSupported, "requires Apple Silicon SMC")

        let usage = try readCurrentStats()

        if let gpuCelsius = usage.gpuCelsius {
            XCTAssertGreaterThan(gpuCelsius, 0)
            XCTAssertLessThan(gpuCelsius, 130)
        }
    }

    private func readCurrentStats() throws -> TemperatureUsage {
        do {
            return try SMCTemperatureProvider().currentStats()
        } catch SMCTemperatureError.serviceNotFound {
            throw XCTSkip("SMC not exposed on this host")
        }
    }
}
