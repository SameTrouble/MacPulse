import Foundation

enum SamplingInterval {
    static let range: ClosedRange<TimeInterval> = 1...60
}

enum ConfigurationValidationError: Error, Equatable {
    case unknownMetric(String)
    case unsupportedStyle(metricID: String, style: MetricStyle)
    case samplingIntervalOutOfRange(metricID: String, interval: TimeInterval)
    case durationOutOfRange(metricID: String, duration: TimeInterval)
    case colorBandUpperBoundOutOfRange(metricID: String, upperBound: Double)
    case colorBandDuplicateUpperBound(metricID: String, upperBound: Double)
    case colorBandLastUpperBoundNotOne(metricID: String, upperBound: Double)
}

struct InvalidConfigurationError: Error, Equatable {
    let errors: [ConfigurationValidationError]
}

extension AppConfiguration {
    func validationErrors(against registry: MetricRegistry) -> [ConfigurationValidationError] {
        var errors: [ConfigurationValidationError] = []
        for (metricID, interval) in samplingIntervals.sorted(by: { $0.key < $1.key })
        where !SamplingInterval.range.contains(interval) {
            errors.append(.samplingIntervalOutOfRange(metricID: metricID, interval: interval))
        }
        for (metricID, bands) in colorBands.sorted(by: { $0.key < $1.key }) {
            errors.append(contentsOf: colorBandValidationErrors(metricID: metricID, bands: bands))
        }
        for placeholder in placeholders {
            for item in placeholder.items {
                guard let metric = registry.metric(id: item.metricID) else {
                    errors.append(.unknownMetric(item.metricID))
                    continue
                }
                if !metric.supportedStyles.contains(item.style) {
                    errors.append(.unsupportedStyle(metricID: item.metricID, style: item.style))
                }
                if !CarouselItem.durationRange.contains(item.duration) {
                    errors.append(.durationOutOfRange(metricID: item.metricID, duration: item.duration))
                }
            }
        }
        return errors
    }
}

private func colorBandValidationErrors(
    metricID: String,
    bands: [ColorBand]
) -> [ConfigurationValidationError] {
    guard !bands.isEmpty else { return [] }
    var errors: [ConfigurationValidationError] = []
    let sorted = bands.sorted { $0.upperBound < $1.upperBound }
    for band in sorted where !ColorBand.upperBoundRange.contains(band.upperBound) {
        errors.append(.colorBandUpperBoundOutOfRange(metricID: metricID, upperBound: band.upperBound))
    }
    for index in sorted.indices.dropFirst() {
        let previous = sorted[index - 1].upperBound
        let current = sorted[index].upperBound
        if current <= previous {
            errors.append(.colorBandDuplicateUpperBound(metricID: metricID, upperBound: current))
        }
    }
    if let last = sorted.last,
       ColorBand.upperBoundRange.contains(last.upperBound),
       last.upperBound != 1.0 {
        errors.append(.colorBandLastUpperBoundNotOne(metricID: metricID, upperBound: last.upperBound))
    }
    return errors
}
