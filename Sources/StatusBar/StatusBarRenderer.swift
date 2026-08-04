import AppKit

enum StatusBarRenderer {
    static func render(
        button: NSStatusBarButton,
        entry: CarouselItem,
        metric: Metric?,
        sample: MetricSample?,
        activeColor: NSColor?
    ) {
        switch entry.style {
        case .progressBar:
            button.title = ""
            button.imagePosition = .imageOnly
            button.image = ProgressBarImage.makeImage(fraction: sample?.fraction, color: activeColor)
        case .iconAndText:
            if let metric {
                button.image = iconImage(
                    symbolName: metric.symbolName,
                    accessibilityDescription: metric.displayNameKey.rawValue,
                    color: activeColor
                )
                button.imagePosition = .imageLeading
            } else {
                button.image = nil
            }
            setTitle(button, text: sample?.text ?? "--", color: activeColor)
        case .text:
            button.image = nil
            setTitle(button, text: sample?.text ?? "--", color: activeColor)
        }
    }

    static func attributedTitle(text: String, color: NSColor?) -> NSAttributedString? {
        guard let color else { return nil }
        return NSAttributedString(string: text, attributes: [.foregroundColor: color])
    }

    static func iconImage(
        symbolName: String,
        accessibilityDescription: String?,
        color: NSColor?
    ) -> NSImage? {
        guard let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: accessibilityDescription) else {
            return nil
        }
        guard let color else {
            image.isTemplate = true
            return image
        }
        let configured = image.withSymbolConfiguration(.init(paletteColors: [color])) ?? image
        configured.isTemplate = false
        return configured
    }

    private static func setTitle(_ button: NSButton, text: String, color: NSColor?) {
        if let attributed = attributedTitle(text: text, color: color) {
            button.attributedTitle = attributed
        } else {
            button.title = text
        }
    }
}
