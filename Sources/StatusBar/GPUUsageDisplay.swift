import Foundation

enum GPUUsageDisplay {
    static let widestText = "100%"

    static func buttonTitle(for usage: GPUUsage?) -> String {
        usage.map { percent($0.deviceUtilization) } ?? "--"
    }

    static func percent(_ fraction: Double) -> String {
        "\(Int((fraction * 100).rounded()))%"
    }
}
