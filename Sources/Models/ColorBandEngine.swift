import Foundation

enum ColorBandEngine {
    static func matchingBand(fraction: Double?, bands: [ColorBand]) -> ColorBand? {
        guard let fraction else { return nil }
        let sorted = bands.sorted { $0.upperBound < $1.upperBound }
        return sorted.first { fraction <= $0.upperBound }
    }
}
