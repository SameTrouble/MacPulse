import Darwin
import Foundation

enum SamplingError: Error {
    case hostInfoFailed
}

struct HostProcessorInfoProvider: CPUTickProviding {
    func currentTicks() throws -> [CPUTick] {
        var info: processor_info_array_t?
        var infoCount = mach_msg_type_number_t(0)
        var cpuCount = natural_t(0)
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &cpuCount,
            &info,
            &infoCount
        )
        guard result == KERN_SUCCESS, let info else { throw SamplingError.hostInfoFailed }

        defer {
            let bytes = vm_size_t(infoCount) * vm_size_t(MemoryLayout<integer_t>.size)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), bytes)
        }

        return info.withMemoryRebound(to: processor_cpu_load_info.self, capacity: Int(cpuCount)) { loads in
            (0..<Int(cpuCount)).map { index in
                let ticks = loads[index].cpu_ticks
                return CPUTick(
                    user: UInt64(ticks.0),
                    system: UInt64(ticks.1),
                    idle: UInt64(ticks.2),
                    nice: UInt64(ticks.3)
                )
            }
        }
    }
}
