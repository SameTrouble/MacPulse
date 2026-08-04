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

    func testCoalescesConsecutiveRefreshesWithinWindow() throws {
        let usage = TemperatureUsage(cpuCelsius: 42, gpuCelsius: 40)
        let provider = FakeTemperatureProvider(result: .success(usage))
        let sampler = TemperatureSampler(provider: provider, coalesceInterval: 1)

        XCTAssertEqual(try sampler.refresh(), usage)
        XCTAssertEqual(try sampler.refresh(), usage)
        XCTAssertEqual(provider.callCount, 1)
    }

    func testRefreshesAgainWhenCoalesceDisabled() throws {
        let usage = TemperatureUsage(cpuCelsius: 42, gpuCelsius: 40)
        let provider = FakeTemperatureProvider(result: .success(usage))
        let sampler = TemperatureSampler(provider: provider, coalesceInterval: 0)

        XCTAssertEqual(try sampler.refresh(), usage)
        XCTAssertEqual(try sampler.refresh(), usage)
        XCTAssertEqual(provider.callCount, 2)
    }
}
