import Foundation

enum CPUUsageDisplay {
    static let widestText = "100%"

    static func buttonTitle(for usage: CPUUsage?) -> String {
        usage.map { percent($0.overall) } ?? "--"
    }

    static func percent(_ fraction: Double) -> String {
        "\(Int((fraction * 100).rounded()))%"
    }
}
