import Foundation

enum MemoryUsageDisplay {
    private static let gigabyte = UInt64(1024 * 1024 * 1024)

    static func buttonTitle(for usage: MemoryUsage?) -> String {
        usage.map { gigabytes($0.usedBytes) } ?? "--"
    }

    static func gigabytes(_ bytes: UInt64) -> String {
        String(format: "%.1f GB", Double(bytes) / Double(gigabyte))
    }

    static func pressureLabel(_ pressure: MemoryPressure) -> String {
        switch pressure {
        case .normal:
            "正常"
        case .warning:
            "警告"
        case .critical:
            "严重"
        }
    }
}
