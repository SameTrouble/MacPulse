import Foundation
@testable import MacPulse

final class FakeTickProvider: CPUTickProviding {
    var result: Result<[CPUTick], Error>

    init(result: Result<[CPUTick], Error>) {
        self.result = result
    }

    func currentTicks() throws -> [CPUTick] {
        try result.get()
    }
}

struct SamplingTestError: Error {}

final class FakeGPUStatsProvider: GPUStatsProviding {
    var result: Result<GPUStats, Error>

    init(result: Result<GPUStats, Error>) {
        self.result = result
    }

    func currentStats() throws -> GPUStats {
        try result.get()
    }
}

final class FakeMemoryStatsProvider: MemoryStatsProviding {
    var result: Result<MemoryStats, Error>

    init(result: Result<MemoryStats, Error>) {
        self.result = result
    }

    func currentStats() throws -> MemoryStats {
        try result.get()
    }
}

extension MemoryStats {
    static func fixture(
        active: UInt64 = 100,
        wired: UInt64 = 200,
        compressor: UInt64 = 0,
        pageSize: UInt64 = 4096,
        totalBytes: UInt64 = 810 * 4096,
        pressureLevel: Int32 = MemoryUsageCalculator.pressureNormal
    ) -> MemoryStats {
        MemoryStats(
            pageFreeCount: 400,
            pageActiveCount: active,
            pageInactiveCount: 60,
            pageWireCount: wired,
            pageSpeculativeCount: 50,
            pageCompressorCount: compressor,
            pageSize: pageSize,
            totalBytes: totalBytes,
            pressureLevel: pressureLevel
        )
    }
}
