import Darwin
import Foundation

enum MemorySamplingError: Error {
    case hostStatisticsFailed
    case totalMemoryFailed
}

struct HostMemoryInfoProvider: MemoryStatsProviding {
    func currentStats() throws -> MemoryStats {
        var infoCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        var info = vm_statistics64_data_t()
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(infoCount)) { stats in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, stats, &infoCount)
            }
        }
        guard result == KERN_SUCCESS else { throw MemorySamplingError.hostStatisticsFailed }

        var totalBytes: UInt64 = 0
        var totalSize = MemoryLayout<UInt64>.size
        let totalResult = sysctlbyname("hw.memsize", &totalBytes, &totalSize, nil, 0)
        guard totalResult == 0 else { throw MemorySamplingError.totalMemoryFailed }

        var pressureLevel = MemoryUsageCalculator.pressureNormal
        var levelSize = MemoryLayout<Int32>.size
        if sysctlbyname("kern.memorystatus_vm_pressure_level", &pressureLevel, &levelSize, nil, 0) != 0 {
            pressureLevel = MemoryUsageCalculator.pressureNormal
        }

        return MemoryStats(
            pageFreeCount: UInt64(info.free_count),
            pageActiveCount: UInt64(info.active_count),
            pageInactiveCount: UInt64(info.inactive_count),
            pageWireCount: UInt64(info.wire_count),
            pageSpeculativeCount: UInt64(info.speculative_count),
            pageCompressorCount: UInt64(info.compressor_page_count),
            pageSize: UInt64(vm_kernel_page_size),
            totalBytes: totalBytes,
            pressureLevel: pressureLevel
        )
    }
}
