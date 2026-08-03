import Foundation

enum MemoryUsageCalculator {
    static let pressureNormal: Int32 = 0
    static let pressureWarning: Int32 = 1
    static let pressureCritical: Int32 = 2

    static func usage(_ stats: MemoryStats) -> MemoryUsage {
        let usedPages = stats.pageActiveCount + stats.pageWireCount + stats.pageCompressorCount
        return MemoryUsage(
            usedBytes: usedPages * stats.pageSize,
            totalBytes: stats.totalBytes,
            pressure: pressure(level: stats.pressureLevel)
        )
    }

    static func pressure(level: Int32) -> MemoryPressure {
        switch level {
        case pressureWarning:
            .warning
        case pressureCritical:
            .critical
        default:
            .normal
        }
    }
}
