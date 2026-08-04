import AppKit
import SwiftUI

final class SettingsWindowController: NSObject, NSWindowDelegate {
    private enum Constants {
        static let contentSize = NSSize(width: 700, height: 560)
    }

    private let model: ConfigurationModel
    private let registry: MetricRegistry
    private let localization: LocalizationService
    private let loginItem: LoginItemModel
    private let windowFactory: () -> NSWindow

    private var window: NSWindow?
    private var hostingController: NSHostingController<SettingsView>?

    init(
        model: ConfigurationModel,
        registry: MetricRegistry,
        localization: LocalizationService,
        loginItem: LoginItemModel,
        windowFactory: @escaping () -> NSWindow = SettingsWindowController.makeWindow
    ) {
        self.model = model
        self.registry = registry
        self.localization = localization
        self.loginItem = loginItem
        self.windowFactory = windowFactory
        super.init()
    }

    func open() {
        if window == nil {
            createWindow()
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        window?.close()
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
        hostingController = nil
    }

    private func createWindow() {
        let window = windowFactory()
        window.delegate = self
        window.isReleasedWhenClosed = false
        let hostingController = NSHostingController(
            rootView: SettingsView(
                model: model,
                registry: registry,
                localization: localization,
                loginItem: loginItem,
                onClose: { [weak self] in self?.close() }
            )
        )
        window.contentViewController = hostingController
        window.center()
        self.window = window
        self.hostingController = hostingController
    }

    static func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: Constants.contentSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "MacPulse"
        return window
    }
}
