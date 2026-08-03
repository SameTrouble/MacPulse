import Foundation

enum TemperatureUsageDisplay {
    static func buttonTitle(for usage: TemperatureUsage) -> String {
        celsius(usage.cpuCelsius)
    }

    static func celsius(_ value: Double) -> String {
        "\(Int(value.rounded()))°"
    }
}
