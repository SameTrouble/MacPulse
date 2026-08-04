import AppKit
import Foundation

final class PlaceholderController: NSObject, NSMenuDelegate {
    private enum Constants {
        static let minimumSwitchInterval: TimeInterval = 0.05
    }

    private let registry: MetricRegistry
    private let localization: LocalizationProviding
    private let onOpenPreferences: () -> Void
    private var placeholder: Placeholder
    private var configuration: AppConfiguration
    private var engine: CarouselEngine
    private var statusItem: NSStatusItem?
    private var switchTimer: Timer?
    private var isHighlighted = false

    init(
        placeholder: Placeholder,
        configuration: AppConfiguration,
        registry: MetricRegistry,
        localization: LocalizationProviding,
        onOpenPreferences: @escaping () -> Void
    ) {
        self.registry = registry
        self.localization = localization
        self.onOpenPreferences = onOpenPreferences
        self.placeholder = placeholder
        self.configuration = configuration
        self.engine = CarouselEngine(entries: placeholder.items, epoch: Date().timeIntervalSinceReferenceDate)
        super.init()
    }

    func start() {
        guard statusItem == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: fixedWidth)
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        item.menu = menu
        statusItem = item
        refreshDisplay()
        scheduleSwitch()
    }

    func stop() {
        switchTimer?.invalidate()
        switchTimer = nil
        statusItem = nil
    }

    func refreshDisplay() {
        guard let button = statusItem?.button else { return }
        guard let entry = currentEntry() else {
            button.image = nil
            button.title = "--"
            return
        }
        let metric = registry.metric(id: entry.metricID)
        let sample = metric?.currentSample()
        let activeColor = isHighlighted ? nil : activeColor(for: entry, sample: sample)
        StatusBarRenderer.render(
            button: button,
            entry: entry,
            metric: metric,
            sample: sample,
            activeColor: activeColor
        )
    }

    func menuWillOpen(_ menu: NSMenu) {
        isHighlighted = true
        refreshDisplay()
    }

    func menuDidClose(_ menu: NSMenu) {
        isHighlighted = false
        refreshDisplay()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        var renderedAnyMetric = false
        for metricID in placeholder.menuMetricIDs {
            guard let metric = registry.metric(id: metricID) else { continue }
            renderedAnyMetric = true
            menu.addItem(MenuRowFactory.title(localization.text(metric.displayNameKey)))
            for line in metric.menuLines(localizedBy: localization) {
                menu.addItem(MenuRowFactory.data(line))
            }
        }

        if renderedAnyMetric {
            menu.addItem(.separator())
        }

        let preferences = NSMenuItem(
            title: localization.text(.menuPreferences),
            action: #selector(openPreferences),
            keyEquivalent: ","
        )
        preferences.target = self
        menu.addItem(preferences)

        let quit = NSMenuItem(title: localization.text(.menuQuit), action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    @objc private func openPreferences() {
        onOpenPreferences()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func currentEntry() -> CarouselItem? {
        guard let index = engine.index(at: Date().timeIntervalSinceReferenceDate),
              placeholder.items.indices.contains(index) else { return nil }
        return placeholder.items[index]
    }

    private var fixedWidth: CGFloat {
        let widest = placeholder.items.map { contentWidth(for: $0) }.max() ?? 0
        return widest + StatusBarLayout.widthInset * 2
    }

    private func contentWidth(for entry: CarouselItem) -> CGFloat {
        switch entry.style {
        case .progressBar:
            return ProgressBarImage.size.width
        case .iconAndText:
            let textWidth = self.textWidth(for: entry)
            guard let metric = registry.metric(id: entry.metricID),
                  let icon = NSImage(systemSymbolName: metric.symbolName, accessibilityDescription: nil) else {
                return textWidth
            }
            return icon.size.width + StatusBarLayout.iconTextSpacing + textWidth
        case .text:
            return textWidth(for: entry)
        }
    }

    private func textWidth(for entry: CarouselItem) -> CGFloat {
        let widest = registry.metric(id: entry.metricID)?.widestDisplayText() ?? MetricWidth.fallbackText
        let attributed = NSAttributedString(
            string: widest,
            attributes: [.font: NSFont.menuBarFont(ofSize: 0)]
        )
        return attributed.size().width
    }

    private func activeColor(for entry: CarouselItem, sample: MetricSample?) -> NSColor? {
        guard configuration.colorBandsEnabled else { return nil }
        guard let band = ColorBandEngine.matchingBand(
            fraction: sample?.fraction,
            bands: configuration.colorBands[entry.metricID] ?? []
        ) else { return nil }
        return band.color.nsColor
    }

    private func scheduleSwitch() {
        switchTimer?.invalidate()
        switchTimer = nil
        let now = Date().timeIntervalSinceReferenceDate
        guard let next = engine.nextSwitchTime(after: now) else { return }
        let interval = max(next - now, Constants.minimumSwitchInterval)
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            self?.handleSwitch()
        }
        RunLoop.main.add(timer, forMode: .common)
        switchTimer = timer
    }

    private func handleSwitch() {
        refreshDisplay()
        scheduleSwitch()
    }
}
