import Foundation

struct Placeholder: Codable, Equatable, Identifiable {
    let id: UUID
    var items: [CarouselItem]
}

struct AppConfiguration: Codable, Equatable {
    var placeholders: [Placeholder]
    var samplingIntervals: [String: TimeInterval] = [:]
    var colorRulesEnabled: Bool = true
    var colorRules: [String: [ColorRule]] = [:]

    init(placeholders: [Placeholder], samplingIntervals: [String: TimeInterval] = [:]) {
        self.placeholders = placeholders
        self.samplingIntervals = samplingIntervals
    }

    private enum CodingKeys: String, CodingKey {
        case placeholders
        case samplingIntervals
        case colorRulesEnabled
        case colorRules
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placeholders = try container.decode([Placeholder].self, forKey: .placeholders)
        samplingIntervals = try container.decodeIfPresent([String: TimeInterval].self, forKey: .samplingIntervals) ?? [:]
        colorRulesEnabled = try container.decodeIfPresent(Bool.self, forKey: .colorRulesEnabled) ?? true
        colorRules = try container.decodeIfPresent([String: [ColorRule]].self, forKey: .colorRules) ?? [:]
    }

    func samplingInterval(for metric: Metric) -> TimeInterval {
        samplingIntervals[metric.id] ?? metric.defaultSamplingInterval
    }
}

extension AppConfiguration {
    static var defaults: AppConfiguration {
        do {
            let iconAndText = try CarouselItem(
                metricID: CPUMetric.metricID,
                style: .iconAndText,
                duration: CarouselItem.defaultDuration
            )
            let text = try CarouselItem(
                metricID: CPUMetric.metricID,
                style: .text,
                duration: CarouselItem.defaultDuration
            )
            let placeholder = Placeholder(id: UUID(), items: [iconAndText, text])
            return AppConfiguration(placeholders: [placeholder])
        } catch {
            fatalError("invalid default configuration: \(error)")
        }
    }
}
