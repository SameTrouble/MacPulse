import Foundation

enum ColorRuleEngine {
    static func matchingRule(fraction: Double?, rules: [ColorRule]) -> ColorRule? {
        guard let fraction else { return nil }
        return rules.first { $0.threshold <= fraction }
    }
}
