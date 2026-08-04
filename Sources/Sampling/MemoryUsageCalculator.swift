import Foundation

enum MemoryUsageCalculator {
    static func usage(_ stats: MemoryStats) -> MemoryUsage {
        let usedPages = stats.pageActiveCount + stats.pageWireCount + stats.pageCompressorCount
        return MemoryUsage(
            usedBytes: usedPages * stats.pageSize,
            totalBytes: stats.totalBytes
        )
    }
}
