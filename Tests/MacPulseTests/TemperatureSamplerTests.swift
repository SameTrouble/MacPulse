@testable import MacPulse
import XCTest

final class TemperatureSamplerTests: XCTestCase {
    func testReturnsProviderStats() throws {
        let usage = TemperatureUsage(cpuCelsius: 42, gpuCelsius: 40)
        let sampler = TemperatureSampler(provider: FakeTemperatureProvider(result: .success(usage)))

        XCTAssertEqual(try sampler.refresh(), usage)
    }

    func testPropagatesError() {
        let sampler = TemperatureSampler(provider: FakeTemperatureProvider(result: .failure(SamplingTestError())))

        XCTAssertThrowsError(try sampler.refresh())
    }
}
