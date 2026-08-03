@testable import MacPulse
import XCTest

final class CPUUsageSamplerTests: XCTestCase {
    func testReturnsNilOnFirstSample() throws {
        let sampler = CPUUsageSampler(provider: FakeTickProvider(result: .success([CPUTick(user: 10, system: 0, idle: 90, nice: 0)])))

        XCTAssertNil(try sampler.refresh())
    }

    func testComputesUsageBetweenSamples() throws {
        let provider = FakeTickProvider(result: .success([CPUTick(user: 50, system: 0, idle: 50, nice: 0)]))
        let sampler = CPUUsageSampler(provider: provider)
        _ = try sampler.refresh()

        provider.result = .success([CPUTick(user: 70, system: 0, idle: 130, nice: 0)])
        let usage = try sampler.refresh()

        XCTAssertEqual(usage?.overall ?? 0, 0.2, accuracy: 0.0001)
        XCTAssertEqual(usage?.perCore, [0.2])
    }

    func testThrowsWhenProviderFails() {
        let sampler = CPUUsageSampler(provider: FakeTickProvider(result: .failure(SamplingTestError())))

        XCTAssertThrowsError(try sampler.refresh())
    }

    func testUsageIsComputedSinceLastSuccessfulSample() throws {
        let provider = FakeTickProvider(result: .success([CPUTick(user: 10, system: 0, idle: 90, nice: 0)]))
        let sampler = CPUUsageSampler(provider: provider)
        _ = try sampler.refresh()

        provider.result = .failure(SamplingTestError())
        XCTAssertThrowsError(try sampler.refresh())

        provider.result = .success([CPUTick(user: 60, system: 0, idle: 140, nice: 0)])
        let usage = try sampler.refresh()

        XCTAssertEqual(usage?.overall ?? 0, 0.5, accuracy: 0.0001)
    }
}
