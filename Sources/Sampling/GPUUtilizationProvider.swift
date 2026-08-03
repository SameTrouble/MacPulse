import Foundation
import IOKit

enum GPUSamplingError: Error {
    case serviceNotFound
    case utilizationUnavailable
}

protocol GPUUtilizationProviding {
    func currentUtilization() throws -> GPUUtilization
}

struct AGXGPUUtilizationProvider: GPUUtilizationProviding {
    private enum Keys {
        static let service = "AGXAccelerator"
        static let statistics = "PerformanceStatistics"
        static let deviceUtilization = "Device Utilization %"
    }

    static var isSupported: Bool {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(Keys.service))
        guard service != 0 else { return false }
        IOObjectRelease(service)
        return true
    }

    func currentUtilization() throws -> GPUUtilization {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(Keys.service))
        guard service != 0 else { throw GPUSamplingError.serviceNotFound }
        defer { IOObjectRelease(service) }

        guard let statistics = readStatistics(from: service),
              let percent = statistics[Keys.deviceUtilization] as? NSNumber else {
            throw GPUSamplingError.utilizationUnavailable
        }
        return GPUUtilization(device: percent.doubleValue / 100)
    }

    private func readStatistics(from service: io_service_t) -> [String: Any]? {
        let property = IORegistryEntryCreateCFProperty(service, Keys.statistics as CFString, kCFAllocatorDefault, 0)
        return property?.takeRetainedValue() as? [String: Any]
    }
}
