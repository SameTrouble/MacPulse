import Foundation

enum PaletteColor: String, Codable, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case gray
}

struct ColorRule: Codable, Equatable, Identifiable {
    static let thresholdRange: ClosedRange<Double> = 0...1

    let id: UUID
    var threshold: Double
    var color: PaletteColor

    init(threshold: Double, color: PaletteColor) throws {
        guard Self.thresholdRange.contains(threshold) else {
            throw ConfigurationError.thresholdOutOfRange(threshold)
        }
        id = UUID()
        self.threshold = threshold
        self.color = color
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case threshold
        case color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let threshold = try container.decode(Double.self, forKey: .threshold)
        let color = try container.decode(PaletteColor.self, forKey: .color)
        guard Self.thresholdRange.contains(threshold) else {
            throw DecodingError.dataCorruptedError(
                forKey: .threshold,
                in: container,
                debugDescription: "threshold must be within 0–1"
            )
        }
        self.id = id
        self.threshold = threshold
        self.color = color
    }
}
