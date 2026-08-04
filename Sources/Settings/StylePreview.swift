import AppKit

enum StylePreview {
    static let sampleText = "73%"

    static func image(for style: MetricStyle) -> NSImage {
        switch style {
        case .progressBar:
            return ProgressBarImage.makeImage(fraction: 0.73)
        case .text:
            return textImage(sampleText)
        case .iconAndText:
            return iconAndTextImage()
        }
    }

    private static func iconAndTextImage() -> NSImage {
        guard let icon = NSImage(systemSymbolName: "cpu.fill", accessibilityDescription: nil) else {
            return textImage(sampleText)
        }
        let text = textImage(sampleText)
        let width = icon.size.width + StatusBarLayout.iconTextSpacing + text.size.width
        let height = max(icon.size.height, text.size.height)
        let image = NSImage(size: NSSize(width: width, height: height))
        image.isTemplate = true
        image.lockFocus()
        icon.draw(
            at: NSPoint(x: 0, y: (height - icon.size.height) / 2),
            from: NSRect(origin: .zero, size: icon.size),
            operation: .sourceOver,
            fraction: 1
        )
        text.draw(
            at: NSPoint(x: icon.size.width + StatusBarLayout.iconTextSpacing, y: (height - text.size.height) / 2),
            from: NSRect(origin: .zero, size: text.size),
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
