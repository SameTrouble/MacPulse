@testable import MacPulse
import XCTest

final class CarouselItemTests: XCTestCase {
    func testDefaultDurationIsThreeSeconds() throws {
        let item = try CarouselItem(metricID: "cpu", style: .iconAndText)
        XCTAssertEqual(item.duration, 3)
    }

    func testAcceptsDurationAtBounds() throws {
        XCTAssertEqual(try CarouselItem(metricID: "cpu", style: .iconAndText, duration: 1).duration, 1)
        XCTAssertEqual(try CarouselItem(metricID: "cpu", style: .iconAndText, duration: 60).duration, 60)
    }

    func testRejectsDurationBelowOneSecond() {
        XCTAssertThrowsError(try CarouselItem(metricID: "cpu", style: .iconAndText, duration: 0.5))
    }

    func testRejectsDurationAboveSixtySeconds() {
        XCTAssertThrowsError(try CarouselItem(metricID: "cpu", style: .iconAndText, duration: 61))
    }

    func testCodableRoundTrip() throws {
        let item = try CarouselItem(metricID: "cpu", style: .text, duration: 5)

        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(CarouselItem.self, from: data)

        XCTAssertEqual(decoded, item)
    }

    func testDecodingOmittedDurationDefaultsToThreeSeconds() throws {
        let json = #"{"metricID": "cpu", "style": "iconAndText"}"#

        let decoded = try JSONDecoder().decode(CarouselItem.self, from: Data(json.utf8))

        XCTAssertEqual(decoded.duration, 3)
    }

    func testDecodingRejectsOutOfRangeDuration() {
        let json = #"{"metricID": "cpu", "style": "iconAndText", "duration": 0}"#

        XCTAssertThrowsError(try JSONDecoder().decode(CarouselItem.self, from: Data(json.utf8)))
    }
}
