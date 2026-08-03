@testable import MacPulse
import XCTest

final class AppConfigurationColorRulesTests: XCTestCase {
    func testDefaultsHaveColorRulesEnabled() throws {
        let configuration = AppConfiguration(placeholders: [])

        XCTAssertTrue(configuration.colorRulesEnabled)
        XCTAssertEqual(configuration.colorRules, [:])
    }

    func testDecodingLegacyJSONKeepsColorRulesEnabled() throws {
        let json = #"{"placeholders": [], "samplingIntervals": {"cpu": 4}}"#

        let decoded = try JSONDecoder().decode(AppConfiguration.self, from: Data(json.utf8))

        XCTAssertTrue(decoded.colorRulesEnabled)
        XCTAssertEqual(decoded.colorRules, [:])
    }

    func testCodableRoundTripPreservesColorRules() throws {
        var configuration = AppConfiguration(placeholders: [])
        configuration.colorRulesEnabled = false
        configuration.colorRules["cpu"] = [
            try ColorRule(threshold: 0.8, color: .red),
            try ColorRule(threshold: 0.5, color: .orange)
        ]

        let data = try JSONEncoder().encode(configuration)
        let decoded = try JSONDecoder().decode(AppConfiguration.self, from: data)

        XCTAssertEqual(decoded, configuration)
    }

    func testDecodingRejectsOutOfRangeRuleThreshold() {
        let json = #"{"placeholders": [], "colorRules": {"cpu": [{"threshold": 1.2, "color": "red"}]}}"#

        XCTAssertThrowsError(try JSONDecoder().decode(AppConfiguration.self, from: Data(json.utf8)))
    }
}
