import Foundation

enum MemoryUsageDisplay {
    static let widestText = "999.9 GB"
    private static let gigabyte = UInt64(1024 * 1024 * 1024)

    static func buttonTitle(for usage: MemoryUsage?) -> String {
        usage.map { gigabytes($0.usedBytes) } ?? "--"
    }

    static func gigabytes(_ bytes: UInt64) -> String {
        String(format: "%.1f GB", Double(bytes) / Double(gigabyte))
    }
}
