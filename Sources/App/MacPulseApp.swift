import AppKit
import SwiftUI

@main
struct MacPulseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(model: appDelegate.configurationModel, registry: appDelegate.registry)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum Constants {
        static let samplingTick: TimeInterval = 1
    }

    let registry: MetricRegistry
    let configurationModel: ConfigurationModel
    private var manager: PlaceholderManager?
    private var samplingTimer: Timer?
    private var lastSample: [String: Date] = [:]

    override init() {
        let registry = MetricRegistry()
        registry.register(CPUMetric())
        if AGXGPUUtilizationProvider.isSupported {
            registry.register(GPUMetric())
        }
        self.registry = registry
        configurationModel = ConfigurationModel(
            registry: registry,
            store: ConfigurationStore(),
            fallback: Self.makeDefaultConfiguration()
        )
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let manager = PlaceholderManager(registry: registry)
        apply(configurationModel.committed, with: manager)
        self.manager = manager

        configurationModel.onCommit = { [weak self] configuration in
            self?.apply(configuration)
        }

        startSampling()
    }

    private func apply(_ configuration: AppConfiguration, with manager: PlaceholderManager? = nil) {
        do {
            try (manager ?? self.manager)?.apply(configuration)
        } catch {
            assertionFailure("failed to apply committed configuration: \(error)")
        }
        startSampling()
    }

    private func startSampling() {
        samplingTimer?.invalidate()
        lastSample = [:]
        let timer = Timer(timeInterval: Constants.samplingTick, repeats: true) { [weak self] _ in
            self?.sample()
        }
        RunLoop.main.add(timer, forMode: .common)
        samplingTimer = timer
        sample()
    }

    private func sample() {
        let now = Date()
        var sampled = false
        for metric in registry.metrics {
            let interval = configurationModel.committed.samplingInterval(for: metric)
            if let last = lastSample[metric.id], now.timeIntervalSince(last) < interval { continue }
            metric.refresh()
            lastSample[metric.id] = now
            sampled = true
        }
        if sampled {
            manager?.refreshDisplays()
        }
    }

    private static func makeDefaultConfiguration() -> AppConfiguration {
        do {
            let iconAndText = try CarouselItem(metricID: CPUMetric.metricID, style: .iconAndText, duration: 3)
            let text = try CarouselItem(metricID: CPUMetric.metricID, style: .text, duration: 3)
            let fixedPlaceholder = Placeholder(id: UUID(), items: [iconAndText])
            let rotatingPlaceholder = Placeholder(id: UUID(), items: [iconAndText, text])
            return AppConfiguration(placeholders: [fixedPlaceholder, rotatingPlaceholder])
        } catch {
            fatalError("invalid default configuration: \(error)")
        }
    }
}
