import IOKit
@testable import MacPulse
import XCTest

final class AGXGPUUtilizationProviderTests: XCTestCase {
    func testReadsUtilizationOnAppleSilicon() throws {
        #if !arch(arm64)
        throw XCTSkip("AGX only exists on Apple Silicon")
        #else
        XCTAssertTrue(AGXGPUUtilizationProvider.isSupported)

        let utilization = try AGXGPUUtilizationProvider().currentUtilization()

        XCTAssertTrue((0...1).contains(utilization.device))
        #endif
    }

    func testIsSupportedMatchesServicePresence() {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AGXAccelerator"))
        defer { if service != 0 { IOObjectRelease(service) } }

        XCTAssertEqual(AGXGPUUtilizationProvider.isSupported, service != 0)
    }
}
