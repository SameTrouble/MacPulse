import Foundation

enum SMCTemperatureDecoder {
    static func decode(bytes: [UInt8], dataType: String) -> Double? {
        switch dataType {
        case "sp78":
            guard bytes.count >= 2 else { return nil }
            let raw = UInt16(bytes[0]) << 8 | UInt16(bytes[1])
            return Double(Int16(bitPattern: raw)) / 256
        case "flt ":
            guard bytes.count >= 4 else { return nil }
            return Double(bytes.withUnsafeBytes { $0.load(as: Float.self) })
        case "ui16":
            guard bytes.count >= 2 else { return nil }
            return Double(UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
        case "ui8":
            guard bytes.count >= 1 else { return nil }
            return Double(bytes[0])
        default:
            return nil
        }
    }
}
