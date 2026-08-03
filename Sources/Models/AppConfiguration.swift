import Foundation

struct Placeholder: Codable, Equatable, Identifiable {
    let id: UUID
    var items: [CarouselItem]
}

struct AppConfiguration: Codable, Equatable {
    var placeholders: [Placeholder]
    var samplingIntervals: [String: TimeInterval] = [:]

    init(placeholders: [Placeholder], samplingIntervals: [String: TimeInterval] = [:]) {
        self.placeholders = placeholders
        self.samplingIntervals = samplingIntervals
    }

    private enum CodingKeys: String, CodingKey {
        case placeholders
        case samplingIntervals
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placeholders = try container.decode([Placeholder].self, forKey: .placeholders)
        samplingIntervals = try container.decodeIfPresent([String: TimeInterval].self, forKey: .samplingIntervals) ?? [:]
    }

    func samplingInterval(for metric: Metric) -> TimeInterval {
        samplingIntervals[metric.id] ?? metric.defaultSamplingInterval
    }
}
