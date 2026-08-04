import AppKit

extension PaletteColor {
    var nsColor: NSColor {
        switch self {
        case .white:
            .white
        case .red:
            .systemRed
        case .orange:
            .systemOrange
        case .yellow:
            .systemYellow
        case .green:
            .systemGreen
        case .blue:
            .systemBlue
        case .purple:
            .systemPurple
        case .gray:
            .systemGray
        }
    }
}
