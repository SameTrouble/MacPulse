import AppKit
import SwiftUI

@main
struct MacPulseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum Constants {
        static let samplingTick: TimeInterval = 1
    }

    let registry: MetricRegistry
    let configurationModel: ConfigurationModel
    let localization: LocalizationService
    let loginItem: LoginItemModel
    let settingsWindowController: SettingsWindowController
    private var manager: PlaceholderManager?
    private var samplingTimer: Timer?
    private var lastSample: [String: Date] = [:]

    override init() {
        let registry = MetricRegistry()
        registry.register(CPUMetric())
        registry.register(MemoryMetric())
        if AGXGPUStatsProvider.isSupported {
            registry.register(GPUMetric())
        }
        if SMCTemperatureProvider.isSupported {
            let temperatureSampler = TemperatureSampler()
            registry.register(CPUTemperatureMetric(sampler: temperatureSampler))
            registry.register(GPUTemperatureMetric(sampler: temperatureSampler))
        }
        self.registry = registry
        let localization = LocalizationService()
        self.localization = localization
        configurationModel = ConfigurationModel(
            registry: registry,
            store: ConfigurationStore(),
            fallback: AppConfiguration.defaults
        )
        loginItem = LoginItemModel(manager: SMAppServiceLoginItemManager())
        settingsWindowController = SettingsWindowController(
            model: configurationModel,
            registry: registry,
            localization: localization,
            loginItem: loginItem
        )
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let manager = PlaceholderManager(
            registry: registry,
            localization: localization,
            onOpenPreferences: { [weak settingsWindowController] in
                settingsWindowController?.open()
            }
        )
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
        var intervals: [String: TimeInterval] = [:]
        for metric in registry.metrics {
            intervals[metric.id] = configurationModel.committed.samplingInterval(for: metric)
        }
        let due = SamplingScheduler.dueIDs(now: now, intervals: intervals, lastSample: lastSample)
        guard !due.isEmpty else { return }
        for metric in registry.metrics where due.contains(metric.id) {
            metric.refresh()
            lastSample[metric.id] = now
        }
        manager?.refreshDisplays()
    }
}
