import Foundation

enum TemperatureUsageDisplay {
    static let widestText = "100°"

    static func celsius(_ value: Double) -> String {
        "\(Int(value.rounded()))°"
    }

    static func fraction(celsius: Double) -> Double {
        min(max(celsius / 100, 0), 1)
    }
}
