import Foundation

enum PaletteColor: String, Codable, CaseIterable {
    case white
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case gray
}

struct ColorBand: Codable, Equatable, Identifiable {
    static let upperBoundRange: ClosedRange<Double> = 0...1

    let id: UUID
    var upperBound: Double
    var color: PaletteColor

    init(upperBound: Double, color: PaletteColor) throws {
        guard Self.upperBoundRange.contains(upperBound) else {
            throw ConfigurationError.upperBoundOutOfRange(upperBound)
        }
        id = UUID()
        self.upperBound = upperBound
        self.color = color
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case upperBound
        case color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let upperBound = try container.decode(Double.self, forKey: .upperBound)
        let color = try container.decode(PaletteColor.self, forKey: .color)
        guard Self.upperBoundRange.contains(upperBound) else {
            throw DecodingError.dataCorruptedError(
                forKey: .upperBound,
                in: container,
                debugDescription: "upperBound must be within 0–1"
            )
        }
        self.id = id
        self.upperBound = upperBound
        self.color = color
    }
}
