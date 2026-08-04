import Foundation

struct Placeholder: Codable, Equatable, Identifiable {
    let id: UUID
    var items: [CarouselItem]
    var menuMetricIDs: [String]

    init(id: UUID, items: [CarouselItem], menuMetricIDs: [String] = []) {
        self.id = id
        self.items = items
        self.menuMetricIDs = menuMetricIDs
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case items
        case menuMetricIDs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        items = try container.decode([CarouselItem].self, forKey: .items)
        menuMetricIDs = try container.decodeIfPresent([String].self, forKey: .menuMetricIDs) ?? []
    }
}

struct AppConfiguration: Codable, Equatable {
    var placeholders: [Placeholder]
    var samplingIntervals: [String: TimeInterval] = [:]
    var colorBandsEnabled: Bool = true
    var colorBands: [String: [ColorBand]] = [:]

    init(placeholders: [Placeholder], samplingIntervals: [String: TimeInterval] = [:]) {
        self.placeholders = placeholders
        self.samplingIntervals = samplingIntervals
    }

    private enum CodingKeys: String, CodingKey {
        case placeholders
        case samplingIntervals
        case colorBandsEnabled
        case colorBands
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placeholders = try container.decode([Placeholder].self, forKey: .placeholders)
        samplingIntervals = try container.decodeIfPresent([String: TimeInterval].self, forKey: .samplingIntervals) ?? [:]
        colorBandsEnabled = try container.decodeIfPresent(Bool.self, forKey: .colorBandsEnabled) ?? true
        colorBands = try container.decodeIfPresent([String: [ColorBand]].self, forKey: .colorBands) ?? [:]
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
            let placeholder = Placeholder(
                id: UUID(),
                items: [iconAndText, text],
                menuMetricIDs: [CPUMetric.metricID]
            )
            return AppConfiguration(placeholders: [placeholder])
        } catch {
            fatalError("invalid default configuration: \(error)")
        }
    }
}
