import Foundation

struct MemoryStats {
    let pageFreeCount: UInt64
    let pageActiveCount: UInt64
    let pageInactiveCount: UInt64
    let pageWireCount: UInt64
    let pageSpeculativeCount: UInt64
    let pageCompressorCount: UInt64
    let pageSize: UInt64
    let totalBytes: UInt64
}

struct MemoryUsage: Equatable {
    let usedBytes: UInt64
    let totalBytes: UInt64

    var fraction: Double {
        totalBytes == 0 ? 0 : Double(usedBytes) / Double(totalBytes)
    }
}
