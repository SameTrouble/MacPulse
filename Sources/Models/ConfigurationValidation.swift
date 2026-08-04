import Foundation

enum SamplingInterval {
    static let range: ClosedRange<TimeInterval> = 1...60
}

enum ConfigurationValidationError: Error, Equatable {
    case unknownMetric(String)
    case unsupportedStyle(metricID: String, style: MetricStyle)
    case samplingIntervalOutOfRange(metricID: String, interval: TimeInterval)
    case durationOutOfRange(metricID: String, duration: TimeInterval)
    case colorRuleThresholdOutOfRange(metricID: String, threshold: Double)
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
        for (metricID, rules) in colorRules.sorted(by: { $0.key < $1.key }) {
            for rule in rules where !ColorRule.thresholdRange.contains(rule.threshold) {
                errors.append(.colorRuleThresholdOutOfRange(metricID: metricID, threshold: rule.threshold))
            }
        }
        for placeholder in placeholders {
            for metricID in placeholder.menuMetricIDs where registry.metric(id: metricID) == nil {
                errors.append(.unknownMetric(metricID))
            }
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
