import Foundation
import IOKit

enum SMCTemperatureError: Error, Equatable {
    case matchingFailed
    case getMatchingServicesFailed(kern_return_t)
    case openFailed(kern_return_t)
    case serviceNotFound
    case noReadableSensor
}

protocol TemperatureStatsProviding {
    func currentStats() throws -> TemperatureUsage
}

struct SMCTemperatureProvider: TemperatureStatsProviding {
    #if arch(arm64)
    static let isSupported = true
    #else
    static let isSupported = false
    #endif

    private enum Constants {
        static let serviceName = "AppleSMC"
        static let kernelIndex: UInt32 = 2
        static let readKeyInfo: UInt8 = 9
        static let readBytes: UInt8 = 5

        static let cpuKeys = [
            "Tp01", "Tp03", "Tp05", "Tp07", "Tp09", "Tp0B", "Tp0D", "Tp0F",
            "Tp0H", "Tp0L", "Tp0P", "Tp0T", "Tp0X", "Tp0V", "Tp0Y", "Tp0b",
            "Tp0e", "Tp0f", "Tp0j", "Tp1h", "Tp1t", "Tp1p", "Tp1l",
            "Te05", "Te0L", "Te0P", "Te0S", "Te09", "Te0H",
            "Tf04", "Tf09", "Tf0A", "Tf0B", "Tf0D", "Tf0E",
            "Tf44", "Tf49", "Tf4A", "Tf4B", "Tf4D", "Tf4E"
        ]
        static let gpuKeys = [
            "Tg05", "Tg0D", "Tg0L", "Tg0T",
            "Tg0f", "Tg0j",
            "Tg0G", "Tg0H", "Tg1U", "Tg1k", "Tg0K", "Tg0d", "Tg0e", "Tg0k",
            "Tf14", "Tf18", "Tf19", "Tf1A", "Tf24", "Tf28", "Tf29", "Tf2A"
        ]
    }

    private static var readableCPUKeys: [String]?
    private static var readableGPUKeys: [String]?

    func currentStats() throws -> TemperatureUsage {
        let connection = try Self.openConnection()
        defer { IOServiceClose(connection) }

        let cpu = try Self.averageTemperature(pool: Constants.cpuKeys, cachedKeys: &Self.readableCPUKeys, connection: connection)
        let gpu = try? Self.averageTemperature(pool: Constants.gpuKeys, cachedKeys: &Self.readableGPUKeys, connection: connection)
        return TemperatureUsage(cpuCelsius: cpu, gpuCelsius: gpu)
    }

    private static func openConnection() throws -> io_connect_t {
        guard let matching = IOServiceMatching(Constants.serviceName) else {
            throw SMCTemperatureError.matchingFailed
        }
        var iterator: io_iterator_t = 0
        let matchingResult = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
        guard matchingResult == kIOReturnSuccess else {
            throw SMCTemperatureError.getMatchingServicesFailed(matchingResult)
        }
        defer { IOObjectRelease(iterator) }

        let device = IOIteratorNext(iterator)
        guard device != 0 else {
            throw SMCTemperatureError.serviceNotFound
        }
        defer { IOObjectRelease(device) }

        var connection: io_connect_t = 0
        let openResult = IOServiceOpen(device, mach_task_self_, 0, &connection)
        guard openResult == kIOReturnSuccess else {
            throw SMCTemperatureError.openFailed(openResult)
        }
        return connection
    }

    private static func averageTemperature(pool: [String], cachedKeys: inout [String]?, connection: io_connect_t) throws -> Double {
        let keys = cachedKeys ?? pool.filter { readValue(key: $0, connection: connection) != nil }
        if !keys.isEmpty {
            cachedKeys = keys
        }
        guard !keys.isEmpty else { throw SMCTemperatureError.noReadableSensor }

        let values = keys.compactMap { readValue(key: $0, connection: connection) }
        guard !values.isEmpty else { throw SMCTemperatureError.noReadableSensor }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func readValue(key: String, connection: io_connect_t) -> Double? {
        var input = SMCKeyData()
        var output = SMCKeyData()
        input.key = fourCharCode(key)
        input.data8 = Constants.readKeyInfo

        let size = MemoryLayout<SMCKeyData>.stride
        var outputSize = size

        var result = IOConnectCallStructMethod(connection, Constants.kernelIndex, &input, size, &output, &outputSize)
        guard result == kIOReturnSuccess else { return nil }

        let dataSize = output.keyInfo.dataSize
        let dataType = dataTypeString(output.keyInfo.dataType)
        guard dataSize > 0 else { return nil }

        input.keyInfo.dataSize = dataSize
        input.data8 = Constants.readBytes
        result = IOConnectCallStructMethod(connection, Constants.kernelIndex, &input, size, &output, &outputSize)
        guard result == kIOReturnSuccess else { return nil }

        var bytes = [UInt8](repeating: 0, count: 32)
        memcpy(&bytes, &output.bytes, Int(min(dataSize, 32)))

        guard bytes.contains(where: { $0 != 0 }) else { return nil }
        return SMCTemperatureDecoder.decode(bytes: bytes, dataType: dataType)
    }

    private static func fourCharCode(_ string: String) -> UInt32 {
        string.utf8.reduce(0) { $0 << 8 | UInt32($1) }
    }

    private static func dataTypeString(_ value: UInt32) -> String {
        var bytes = [UInt8](repeating: 0, count: 4)
        bytes[0] = UInt8((value >> 24) & 0xff)
        bytes[1] = UInt8((value >> 16) & 0xff)
        bytes[2] = UInt8((value >> 8) & 0xff)
        bytes[3] = UInt8(value & 0xff)
        return String(bytes: bytes, encoding: .ascii) ?? ""
    }
}

private struct SMCKeyData {
    struct VersionData {
        var major: UInt8 = 0
        var minor: UInt8 = 0
        var build: UInt8 = 0
        var reserved: UInt8 = 0
        var release: UInt16 = 0
    }

    struct LimitData {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }

    struct KeyInfo {
        var dataSize: UInt32 = 0
        var dataType: UInt32 = 0
        var dataAttributes: UInt8 = 0
    }

    // swiftlint:disable:next large_tuple
    typealias Bytes = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                       UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                       UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                       UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    var key: UInt32 = 0
    var vers = VersionData()
    var pLimitData = LimitData()
    var keyInfo = KeyInfo()
    var padding: UInt16 = 0
    var result: UInt8 = 0
    var status: UInt8 = 0
    var data8: UInt8 = 0
    var data32: UInt32 = 0
    var bytes: Bytes = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
}
