import Foundation

enum ConfigurationValidationError: Error, Equatable {
    case unknownMetric(String)
    case unsupportedStyle(metricID: String, style: MetricStyle)
}

struct InvalidConfigurationError: Error, Equatable {
    let errors: [ConfigurationValidationError]
}

extension AppConfiguration {
    func validationErrors(against registry: MetricRegistry) -> [ConfigurationValidationError] {
        var errors: [ConfigurationValidationError] = []
        for placeholder in placeholders {
            for item in placeholder.items {
                guard let metric = registry.metric(id: item.metricID) else {
                    errors.append(.unknownMetric(item.metricID))
                    continue
                }
                if !metric.supportedStyles.contains(item.style) {
                    errors.append(.unsupportedStyle(metricID: item.metricID, style: item.style))
                }
            }
        }
        return errors
    }
}
