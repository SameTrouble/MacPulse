import AppKit
import SwiftUI

@main
struct MacPulseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            Text("MacPulse")
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum Constants {
        static let samplingInterval: TimeInterval = 2
    }

    private let registry = MetricRegistry()
    private var manager: PlaceholderManager?
    private var samplingTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        registry.register(CPUMetric())

        let manager = PlaceholderManager(registry: registry)
        do {
            try manager.apply(Self.makeDefaultConfiguration())
        } catch {
            fatalError("invalid default configuration: \(error)")
        }
        self.manager = manager

        let timer = Timer(timeInterval: Constants.samplingInterval, repeats: true) { [weak self] _ in
            self?.sample()
        }
        RunLoop.main.add(timer, forMode: .common)
        samplingTimer = timer
        sample()
    }

    private func sample() {
        for metric in registry.metrics {
            metric.refresh()
        }
        manager?.refreshDisplays()
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
