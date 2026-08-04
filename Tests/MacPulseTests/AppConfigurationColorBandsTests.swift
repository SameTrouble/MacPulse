@testable import MacPulse
import XCTest

final class AppConfigurationColorBandsTests: XCTestCase {
    func testDefaultsHaveColorBandsEnabled() throws {
        let configuration = AppConfiguration(placeholders: [])

        XCTAssertTrue(configuration.colorBandsEnabled)
        XCTAssertEqual(configuration.colorBands, [:])
    }

    func testDecodingLegacyJSONKeepsColorBandsEnabled() throws {
        let json = #"{"placeholders": [], "samplingIntervals": {"cpu": 4}}"#

        let decoded = try JSONDecoder().decode(AppConfiguration.self, from: Data(json.utf8))

        XCTAssertTrue(decoded.colorBandsEnabled)
        XCTAssertEqual(decoded.colorBands, [:])
    }

    func testDecodingIgnoresLegacyColorRulesKeys() throws {
        let json = """
        {
          "placeholders": [],
          "colorRulesEnabled": false,
          "colorRules": {"cpu": [{"threshold": 0.8, "color": "red"}]}
        }
        """

        let decoded = try JSONDecoder().decode(AppConfiguration.self, from: Data(json.utf8))

        XCTAssertTrue(decoded.colorBandsEnabled)
        XCTAssertEqual(decoded.colorBands, [:])
    }

    func testCodableRoundTripPreservesColorBands() throws {
        var configuration = AppConfiguration(placeholders: [])
        configuration.colorBandsEnabled = false
        configuration.colorBands["cpu"] = [
            try ColorBand(upperBound: 0.5, color: .yellow),
            try ColorBand(upperBound: 1.0, color: .red)
        ]

        let data = try JSONEncoder().encode(configuration)
        let decoded = try JSONDecoder().decode(AppConfiguration.self, from: data)

        XCTAssertEqual(decoded, configuration)
    }

    func testDecodingRejectsOutOfRangeBandUpperBound() {
        let json = #"{"placeholders": [], "colorBands": {"cpu": [{"upperBound": 1.2, "color": "red"}]}}"#

        XCTAssertThrowsError(try JSONDecoder().decode(AppConfiguration.self, from: Data(json.utf8)))
    }
}
