import AppKit
import Foundation

final class PlaceholderController: NSObject, NSMenuDelegate {
    private enum Constants {
        static let minimumSwitchInterval: TimeInterval = 0.05
    }

    private let registry: MetricRegistry
    private let localization: LocalizationProviding
    private var placeholder: Placeholder
    private var configuration: AppConfiguration
    private var engine: CarouselEngine
    private var statusItem: NSStatusItem?
    private var switchTimer: Timer?

    init(
        placeholder: Placeholder,
        configuration: AppConfiguration,
        registry: MetricRegistry,
        localization: LocalizationProviding
    ) {
        self.registry = registry
        self.localization = localization
        self.placeholder = placeholder
        self.configuration = configuration
        self.engine = CarouselEngine(entries: placeholder.items, epoch: Date().timeIntervalSinceReferenceDate)
        super.init()
    }

    func start() {
        guard statusItem == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
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
            button.contentTintColor = nil
            return
        }
        let metric = registry.metric(id: entry.metricID)
        let sample = metric?.currentSample()
        button.contentTintColor = tintColor(for: entry, sample: sample)
        switch entry.style {
        case .progressBar:
            button.title = ""
            button.imagePosition = .imageOnly
            button.image = ProgressBarImage.makeImage(fraction: sample?.fraction)
        case .iconAndText:
            if let metric {
                button.image = NSImage(
                    systemSymbolName: metric.symbolName,
                    accessibilityDescription: localization.text(metric.displayNameKey)
                )
                button.imagePosition = .imageLeading
            } else {
                button.image = nil
            }
            button.title = sample?.text ?? "--"
        case .text:
            button.image = nil
            button.title = sample?.text ?? "--"
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if let metric = currentMetric() {
            for line in metric.menuLines(localizedBy: localization) {
                let item = NSMenuItem(title: line, action: nil, keyEquivalent: "")
                item.isEnabled = false
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())

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
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func currentEntry() -> CarouselItem? {
        guard let index = engine.index(at: Date().timeIntervalSinceReferenceDate),
              placeholder.items.indices.contains(index) else { return nil }
        return placeholder.items[index]
    }

    private func tintColor(for entry: CarouselItem, sample: MetricSample?) -> NSColor? {
        guard configuration.colorRulesEnabled else { return nil }
        guard let rule = ColorRuleEngine.matchingRule(
            fraction: sample?.fraction,
            rules: configuration.colorRules[entry.metricID] ?? []
        ) else { return nil }
        return rule.color.nsColor
    }

    private func currentMetric() -> Metric? {
        currentEntry().flatMap { registry.metric(id: $0.metricID) }
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
