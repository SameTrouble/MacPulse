@testable import MacPulse
import XCTest

final class PlaceholderConfigurationTests: XCTestCase {
    func testConfigurationCodableRoundTrip() throws {
        let item = try CarouselItem(metricID: "cpu", style: .iconAndText, duration: 4)
        let configuration = AppConfiguration(placeholders: [Placeholder(id: UUID(), items: [item])])

        let data = try JSONEncoder().encode(configuration)
        let decoded = try JSONDecoder().decode(AppConfiguration.self, from: data)

        XCTAssertEqual(decoded, configuration)
    }

    func testPlaceholderPreservesItemOrder() throws {
        let first = try CarouselItem(metricID: "cpu", style: .iconAndText)
        let second = try CarouselItem(metricID: "cpu", style: .text)
        let placeholder = Placeholder(id: UUID(), items: [first, second])

        let data = try JSONEncoder().encode(placeholder)
        let decoded = try JSONDecoder().decode(Placeholder.self, from: data)

        XCTAssertEqual(decoded.items, [first, second])
    }

    func testPlaceholderRoundTripsMenuMetricIDs() throws {
        let item = try CarouselItem(metricID: "cpu", style: .iconAndText)
        let placeholder = Placeholder(id: UUID(), items: [item], menuMetricIDs: ["cpu", "memory"])

        let data = try JSONEncoder().encode(placeholder)
        let decoded = try JSONDecoder().decode(Placeholder.self, from: data)

        XCTAssertEqual(decoded.menuMetricIDs, ["cpu", "memory"])
    }

    func testPlaceholderDefaultsMenuMetricIDsToEmpty() {
        let placeholder = Placeholder(id: UUID(), items: [])

        XCTAssertEqual(placeholder.menuMetricIDs, [])
    }

    func testPlaceholderDecodesLegacyJSONWithoutMenuMetricIDs() throws {
        let item = try CarouselItem(metricID: "cpu", style: .iconAndText)
        let itemJSON = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(item))
        let json: [String: Any] = [
            "id": UUID().uuidString,
            "items": [itemJSON]
        ]
        let data = try JSONSerialization.data(withJSONObject: json)

        let decoded = try JSONDecoder().decode(Placeholder.self, from: data)

        XCTAssertEqual(decoded.menuMetricIDs, [])
        XCTAssertEqual(decoded.items, [item])
    }
}
