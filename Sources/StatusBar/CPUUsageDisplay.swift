import Foundation

enum CPUUsageDisplay {
    static func buttonTitle(for usage: CPUUsage?) -> String {
        usage.map { PercentDisplay.percent($0.overall) } ?? "--"
    }
}
