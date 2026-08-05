import Foundation

enum ValueFormatting {
    static let fallback = "--"

    static let widestPercent = "100%"
    static let widestGigabytes = "999.9 GB"
    static let widestCelsius = "100°"

    private static let gigabyte = UInt64(1024 * 1024 * 1024)

    static func percent(_ fraction: Double) -> String {
        "\(Int((fraction * 100).rounded()))%"
    }

    static func gigabytes(_ bytes: UInt64) -> String {
        String(format: "%.1f GB", Double(bytes) / Double(gigabyte))
    }

    static func celsius(_ value: Double) -> String {
        "\(Int(value.rounded()))°"
    }

    static func fraction(celsius value: Double) -> Double {
        min(max(value / 100, 0), 1)
    }
}
