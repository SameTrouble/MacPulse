import Foundation

enum ColorBandDisplayScale: Equatable {
    case percent
    case celsius

    static func forMetricID(_ metricID: String) -> ColorBandDisplayScale {
        switch metricID {
        case CPUTemperatureMetric.metricID, GPUTemperatureMetric.metricID:
            .celsius
        default:
            .percent
        }
    }

    func rangeLabel(lower: Double, upper: Double) -> String {
        "\(Int(lower * 100))–\(Int(upper * 100))\(unitSuffix)"
    }

    var fullScaleLabel: String {
        "100\(unitSuffix)"
    }

    private var unitSuffix: String {
        switch self {
        case .percent:
            "%"
        case .celsius:
            "°C"
        }
    }
}
