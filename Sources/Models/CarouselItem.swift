import Foundation

enum MetricStyle: String, Codable, CaseIterable {
    case iconAndText
    case text
}

enum ConfigurationError: Error, Equatable {
    case durationOutOfRange(TimeInterval)
}

struct CarouselItem: Codable, Equatable, Identifiable {
    static let durationRange: ClosedRange<TimeInterval> = 1...60
    static let defaultDuration: TimeInterval = 3

    let id: UUID
    var metricID: String
    var style: MetricStyle
    var duration: TimeInterval

    init(metricID: String, style: MetricStyle, duration: TimeInterval = CarouselItem.defaultDuration) throws {
        guard Self.durationRange.contains(duration) else {
            throw ConfigurationError.durationOutOfRange(duration)
        }
        id = UUID()
        self.metricID = metricID
        self.style = style
        self.duration = duration
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case metricID
        case style
        case duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let metricID = try container.decode(String.self, forKey: .metricID)
        let style = try container.decode(MetricStyle.self, forKey: .style)
        let duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? Self.defaultDuration
        guard Self.durationRange.contains(duration) else {
            throw DecodingError.dataCorruptedError(
                forKey: .duration,
                in: container,
                debugDescription: "duration must be within 1–60 seconds"
            )
        }
        self.id = id
        self.metricID = metricID
        self.style = style
        self.duration = duration
    }
}
