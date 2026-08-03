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
}
