@testable import MacPulse
import XCTest

final class CarouselEngineTests: XCTestCase {
    private func item(duration: TimeInterval) throws -> CarouselItem {
        try CarouselItem(metricID: "cpu", style: .iconAndText, duration: duration)
    }

    func testEmptyEntriesHaveNoIndex() throws {
        let engine = CarouselEngine(entries: [], epoch: 0)
        XCTAssertNil(engine.index(at: 0))
        XCTAssertNil(engine.index(at: 100))
    }

    func testSingleEntryIsFixed() throws {
        let engine = CarouselEngine(entries: [try item(duration: 2)], epoch: 0)

        for time: TimeInterval in [0, 2, 10, 100] {
            XCTAssertEqual(engine.index(at: time), 0)
        }
    }

    func testCyclesEntriesByIndividualDurations() throws {
        let engine = CarouselEngine(entries: [try item(duration: 2), try item(duration: 3)], epoch: 0)

        XCTAssertEqual(engine.index(at: 0), 0)
        XCTAssertEqual(engine.index(at: 1.9), 0)
        XCTAssertEqual(engine.index(at: 2), 1)
        XCTAssertEqual(engine.index(at: 4.9), 1)
        XCTAssertEqual(engine.index(at: 5), 0)
        XCTAssertEqual(engine.index(at: 7), 1)
        XCTAssertEqual(engine.index(at: 10), 0)
    }

    func testCyclesAcrossManyLoops() throws {
        let engine = CarouselEngine(entries: [try item(duration: 1), try item(duration: 2), try item(duration: 3)], epoch: 0)

        XCTAssertEqual(engine.index(at: 600), 0)
        XCTAssertEqual(engine.index(at: 601), 1)
        XCTAssertEqual(engine.index(at: 603), 2)
        XCTAssertEqual(engine.index(at: 606), 0)
    }

    func testRespectsEpochOffset() throws {
        let engine = CarouselEngine(entries: [try item(duration: 2), try item(duration: 2)], epoch: 10)

        XCTAssertEqual(engine.index(at: 10), 0)
        XCTAssertEqual(engine.index(at: 12), 1)
        XCTAssertEqual(engine.index(at: 14), 0)
    }

    func testNextSwitchTimeFollowsEntryBoundaries() throws {
        let engine = CarouselEngine(entries: [try item(duration: 2), try item(duration: 3)], epoch: 0)

        XCTAssertEqual(engine.nextSwitchTime(after: 0), 2)
        XCTAssertEqual(engine.nextSwitchTime(after: 1.5), 2)
        XCTAssertEqual(engine.nextSwitchTime(after: 2), 5)
        XCTAssertEqual(engine.nextSwitchTime(after: 4.9), 5)
        XCTAssertEqual(engine.nextSwitchTime(after: 5), 7)
        XCTAssertEqual(engine.nextSwitchTime(after: 7), 10)
    }

    func testNextSwitchTimeIsNilForSingleOrEmptyEntries() throws {
        let single = CarouselEngine(entries: [try item(duration: 2)], epoch: 0)
        let empty = CarouselEngine(entries: [], epoch: 0)

        XCTAssertNil(single.nextSwitchTime(after: 0))
        XCTAssertNil(empty.nextSwitchTime(after: 0))
    }
}
