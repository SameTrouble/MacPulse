import AppKit
import Foundation

final class PlaceholderController: NSObject, NSMenuDelegate {
    private enum Constants {
        static let minimumSwitchInterval: TimeInterval = 0.05
    }

    private let registry: MetricRegistry
    private var placeholder: Placeholder
    private var engine: CarouselEngine
    private var statusItem: NSStatusItem?
    private var switchTimer: Timer?

    init(placeholder: Placeholder, registry: MetricRegistry) {
        self.registry = registry
        self.placeholder = placeholder
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
            return
        }
        let metric = registry.metric(id: entry.metricID)
        let sample = metric?.currentSample()
        if entry.style == .iconAndText, let metric {
            button.image = NSImage(systemSymbolName: metric.symbolName, accessibilityDescription: metric.displayName)
            button.imagePosition = .imageLeading
        } else {
            button.image = nil
        }
        button.title = sample?.text ?? "--"
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if let metric = currentMetric() {
            for line in metric.menuLines() {
                let item = NSMenuItem(title: line, action: nil, keyEquivalent: "")
                item.isEnabled = false
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())

        let preferences = NSMenuItem(title: "偏好设置…", action: #selector(openPreferences), keyEquivalent: ",")
        preferences.target = self
        menu.addItem(preferences)

        let quit = NSMenuItem(title: "退出 MacPulse", action: #selector(quit), keyEquivalent: "q")
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
