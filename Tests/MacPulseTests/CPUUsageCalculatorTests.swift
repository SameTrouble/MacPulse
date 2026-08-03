@testable import MacPulse
import XCTest

final class CPUUsageCalculatorTests: XCTestCase {
    private func tick(user: UInt64 = 0, system: UInt64 = 0, idle: UInt64 = 0, nice: UInt64 = 0) -> CPUTick {
        CPUTick(user: user, system: system, idle: idle, nice: nice)
    }

    func testReturnsNilWhenPreviousIsEmpty() {
        XCTAssertNil(CPUUsageCalculator.usage(previous: [], current: [tick(idle: 100)]))
    }

    func testReturnsNilWhenCoreCountsMismatch() {
        let previous = [tick(idle: 100)]
        let current = [tick(idle: 200), tick(idle: 200)]
        XCTAssertNil(CPUUsageCalculator.usage(previous: previous, current: current))
    }

    func testComputesPerCoreAndTotalUsage() {
        let previous = [tick(), tick()]
        let current = [tick(user: 50, idle: 50), tick(user: 25, idle: 75)]

        let usage = CPUUsageCalculator.usage(previous: previous, current: current)

        XCTAssertEqual(usage?.perCore, [0.5, 0.25])
        XCTAssertEqual(usage?.overall ?? 0, 0.375, accuracy: 0.0001)
    }

    func testCountsSystemAndNiceAsActive() {
        let previous = [tick()]
        let current = [tick(system: 30, idle: 60, nice: 10)]

        let usage = CPUUsageCalculator.usage(previous: previous, current: current)

        XCTAssertEqual(usage?.overall ?? 0, 0.4, accuracy: 0.0001)
    }

    func testReturnsNilWhenCountersWrap() {
        let previous = [tick(user: 100, idle: 100)]
        let current = [tick(user: 50, idle: 250)]

        XCTAssertNil(CPUUsageCalculator.usage(previous: previous, current: current))
    }

    func testZeroDeltaYieldsZeroUsage() {
        let sample = [tick(user: 40, idle: 60)]

        let usage = CPUUsageCalculator.usage(previous: sample, current: sample)

        XCTAssertEqual(usage?.perCore, [0])
        XCTAssertEqual(usage?.overall, 0)
    }
}
