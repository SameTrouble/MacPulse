import AppKit

enum ProgressBarImage {
    static let size = NSSize(width: 28, height: 14)

    static func clampedFraction(_ fraction: Double?) -> Double {
        guard let fraction else { return 0 }
        return min(max(fraction, 0), 1)
    }

    static func fillWidth(for fraction: Double?) -> CGFloat {
        let clamped = clampedFraction(fraction)
        guard clamped > 0 else { return 0 }
        let exact = clamped * Double(size.width)
        return max(1, CGFloat(exact.rounded()))
    }

    static func makeImage(fraction: Double?) -> NSImage {
        let image = NSImage(size: size)
        image.isTemplate = true
        image.lockFocus()
        defer { image.unlockFocus() }
        let radius = size.height / 2
        let track = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: radius, yRadius: radius)
        NSColor.black.withAlphaComponent(0.25).setFill()
        track.fill()
        let width = fillWidth(for: fraction)
        guard width > 0 else { return image }
        let fillRadius = min(radius, width / 2)
        let fillRect = NSRect(x: 0, y: 0, width: width, height: size.height)
        let fill = NSBezierPath(roundedRect: fillRect, xRadius: fillRadius, yRadius: fillRadius)
        NSColor.black.setFill()
        fill.fill()
        return image
    }
}
