import AppKit

enum StylePreview {
    static let sampleFraction = 0.73

    static func sampleText(forMetricID metricID: String) -> String {
        switch metricID {
        case MemoryMetric.metricID:
            return "12.3 GB"
        case CPUTemperatureMetric.metricID, GPUTemperatureMetric.metricID:
            return "45°"
        default:
            return "73%"
        }
    }

    static func image(for style: MetricStyle, symbolName: String, metricID: String) -> NSImage {
        let text = sampleText(forMetricID: metricID)
        switch style {
        case .progressBar:
            return ProgressBarImage.makeImage(fraction: sampleFraction)
        case .text:
            return textImage(text)
        case .iconAndText:
            return iconAndTextImage(symbolName: symbolName, text: text)
        }
    }

    private static func iconAndTextImage(symbolName: String, text: String) -> NSImage {
        guard let icon = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else {
            return textImage(text)
        }
        let textImage = textImage(text)
        let width = icon.size.width + StatusBarLayout.iconTextSpacing + textImage.size.width
        let height = max(icon.size.height, textImage.size.height)
        let image = NSImage(size: NSSize(width: width, height: height))
        image.isTemplate = true
        image.lockFocus()
        icon.draw(
            at: NSPoint(x: 0, y: (height - icon.size.height) / 2),
            from: NSRect(origin: .zero, size: icon.size),
            operation: .sourceOver,
            fraction: 1
        )
        textImage.draw(
            at: NSPoint(x: icon.size.width + StatusBarLayout.iconTextSpacing, y: (height - textImage.size.height) / 2),
            from: NSRect(origin: .zero, size: textImage.size),
            operation: .sourceOver,
            fraction: 1
        )
        image.unlockFocus()
        return image
    }

    private static func textImage(_ text: String) -> NSImage {
        let font = NSFont.menuBarFont(ofSize: 0)
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let size = attributed.size()
        let image = NSImage(size: size)
        image.isTemplate = true
        image.lockFocus()
        attributed.draw(at: .zero)
        image.unlockFocus()
        return image
    }
}
