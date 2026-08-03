import Foundation

enum MetricStyle: String, Codable, CaseIterable {
    case iconAndText
    case text
}

enum ConfigurationError: Error, Equatable {
    case durationOutOfRange(TimeInterval)
}

struct CarouselItem: Codable, Equatable {
    static let durationRange: ClosedRange<TimeInterval> = 1...60
    static let defaultDuration: TimeInterval = 3

    let metricID: String
    let style: MetricStyle
    let duration: TimeInterval

    init(metricID: String, style: MetricStyle, duration: TimeInterval = CarouselItem.defaultDuration) throws {
        guard Self.durationRange.contains(duration) else {
            throw ConfigurationError.durationOutOfRange(duration)
        }
        self.metricID = metricID
        self.style = style
        self.duration = duration
    }

    private enum CodingKeys: String, CodingKey {
        case metricID
        case style
        case duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let metricID = try container.decode(String.self, forKey: .metricID)
        let style = try container.decode(MetricStyle.self, forKey: .style)
        let duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? Self.defaultDuration
        do {
            try self.init(metricID: metricID, style: style, duration: duration)
        } catch {
            throw DecodingError.dataCorruptedError(
                forKey: .duration,
                in: container,
                debugDescription: "duration must be within 1–60 seconds"
            )
        }
    }
}
