@testable import MacPulse
import XCTest

final class ColorRuleEngineTests: XCTestCase {
    private func rule(threshold: Double, color: PaletteColor) throws -> ColorRule {
        try ColorRule(threshold: threshold, color: color)
    }

    func testNilFractionAlwaysReturnsDefaultColor() throws {
        let rules = [try rule(threshold: 0.5, color: .orange)]

        XCTAssertNil(ColorRuleEngine.matchingRule(fraction: nil, rules: rules))
    }

    func testEmptyRulesReturnDefaultColor() {
        XCTAssertNil(ColorRuleEngine.matchingRule(fraction: 0.9, rules: []))
    }

    func testFractionBelowAllThresholdsReturnsDefaultColor() throws {
        let rules = [try rule(threshold: 0.5, color: .orange)]

        XCTAssertNil(ColorRuleEngine.matchingRule(fraction: 0.4, rules: rules))
    }

    func testMatchesFirstRuleWhoseThresholdIsReached() throws {
        let rules = [
            try rule(threshold: 0.8, color: .red),
            try rule(threshold: 0.5, color: .orange)
        ]

        let matched = ColorRuleEngine.matchingRule(fraction: 0.65, rules: rules)

        XCTAssertEqual(matched?.color, .orange)
    }

    func testHighestRuleMatchesWhenAllReached() throws {
        let rules = [
            try rule(threshold: 0.8, color: .red),
            try rule(threshold: 0.5, color: .orange)
        ]

        let matched = ColorRuleEngine.matchingRule(fraction: 0.9, rules: rules)

        XCTAssertEqual(matched?.color, .red)
    }

    func testTopDownOrderWinsOverThresholdLadder() throws {
        let rules = [
            try rule(threshold: 0.5, color: .orange),
            try rule(threshold: 0.8, color: .red)
        ]

        let matched = ColorRuleEngine.matchingRule(fraction: 0.9, rules: rules)

        XCTAssertEqual(matched?.color, .orange)
    }

    func testFractionEqualToThresholdMatches() throws {
        let rules = [try rule(threshold: 0.5, color: .orange)]

        XCTAssertEqual(ColorRuleEngine.matchingRule(fraction: 0.5, rules: rules)?.color, .orange)
    }

    func testZeroFractionMatchesZeroThresholdRule() throws {
        let rules = [try rule(threshold: 0, color: .green)]

        XCTAssertEqual(ColorRuleEngine.matchingRule(fraction: 0, rules: rules)?.color, .green)
    }
}
