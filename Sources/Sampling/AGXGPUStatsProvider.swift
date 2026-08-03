import Foundation
import IOKit

enum GPUSamplingError: Error {
    case serviceMatchingFailed
    case utilizationUnavailable
}

protocol GPUStatsProviding {
    func currentStats() throws -> GPUStats
}

struct AGXGPUStatsProvider: GPUStatsProviding {
    #if arch(arm64)
    static let isSupported = true
    #else
    static let isSupported = false
    #endif

    private enum Constants {
        static let serviceClassName = "AGXAccelerator"
        static let performanceStatisticsKey = "PerformanceStatistics"
        static let deviceUtilizationKey = "Device Utilization %"
    }

    func currentStats() throws -> GPUStats {
        let matching = IOServiceMatching(Constants.serviceClassName)
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            throw GPUSamplingError.serviceMatchingFailed
        }
        defer { IOObjectRelease(iterator) }

        var utilization: Int?
        var device = IOIteratorNext(iterator)
        while device != 0 {
            defer {
                IOObjectRelease(device)
                device = IOIteratorNext(iterator)
            }
            guard let properties = properties(of: device),
                  let stats = properties[Constants.performanceStatisticsKey] as? [String: Any],
                  let value = stats[Constants.deviceUtilizationKey] as? Int else { continue }
            utilization = max(utilization ?? Int.min, value)
        }
        guard let utilization else { throw GPUSamplingError.utilizationUnavailable }
        return GPUStats(deviceUtilizationPercent: utilization)
    }

    private func properties(of device: io_object_t) -> [String: Any]? {
        var properties: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(device, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS,
              let properties else { return nil }
        return properties.takeRetainedValue() as? [String: Any]
    }
}
