@testable import MacPulse
import XCTest

final class SamplingSchedulerTests: XCTestCase {
    private let now = Date(timeIntervalSinceReferenceDate: 1000)

    func testAllMetricsDueOnColdStart() {
        let intervals: [String: TimeInterval] = ["cpu": 2, "memory": 5]

        let due = SamplingScheduler.dueIDs(now: now, intervals: intervals, lastSample: [:])

        XCTAssertEqual(due, ["cpu", "memory"])
    }

    func testNotDueWhenWithinInterval() {
        let intervals: [String: TimeInterval] = ["cpu": 2]
        let lastSample = ["cpu": now.addingTimeInterval(-1)]

        let due = SamplingScheduler.dueIDs(now: now, intervals: intervals, lastSample: lastSample)

        XCTAssertTrue(due.isEmpty)
    }

    func testDueExactlyAtIntervalBoundary() {
        let intervals: [String: TimeInterval] = ["cpu": 2]
        let lastSample = ["cpu": now.addingTimeInterval(-2)]

        let due = SamplingScheduler.dueIDs(now: now, intervals: intervals, lastSample: lastSample)

        XCTAssertEqual(due, ["cpu"])
    }

    func testMixedDueAndNotDue() {
        let intervals: [String: TimeInterval] = ["cpu": 2, "memory": 5]
        let lastSample = [
            "cpu": now.addingTimeInterval(-3),
            "memory": now.addingTimeInterval(-1)
        ]

        let due = SamplingScheduler.dueIDs(now: now, intervals: intervals, lastSample: lastSample)

        XCTAssertEqual(due, ["cpu"])
    }

    func testDifferentIntervalsPerMetric() {
        let intervals: [String: TimeInterval] = ["cpu": 10, "gpu": 1]
        let lastSample = [
            "cpu": now.addingTimeInterval(-5),
            "gpu": now.addingTimeInterval(-5)
        ]

        let due = SamplingScheduler.dueIDs(now: now, intervals: intervals, lastSample: lastSample)

        XCTAssertEqual(due, ["gpu"])
    }
}
