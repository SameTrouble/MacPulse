import AppKit
import Foundation

final class StatusBarController: NSObject, NSMenuDelegate {
    private enum Constants {
        static let samplingInterval: TimeInterval = 2
    }

    private var statusItem: NSStatusItem?
    private let sampler = CPUUsageSampler()
    private var timer: Timer?
    private var usage: CPUUsage?

    func start() {
        guard statusItem == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureButton(item)
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        item.menu = menu
        statusItem = item

        let timer = Timer(timeInterval: Constants.samplingInterval, repeats: true) { [weak self] _ in
            self?.sample()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        sample()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        let header = NSMenuItem(title: "总体 CPU：\(CPUUsageDisplay.buttonTitle(for: usage))", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        if let usage {
            menu.addItem(.separator())
            for (index, core) in usage.perCore.enumerated() {
                let item = NSMenuItem(title: "核心 \(index + 1)：\(CPUUsageDisplay.percent(core))", action: nil, keyEquivalent: "")
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

    private func configureButton(_ item: NSStatusItem) {
        guard let button = item.button else { return }
        button.image = NSImage(systemSymbolName: "cpu.fill", accessibilityDescription: "CPU")
        button.imagePosition = .imageLeading
    }

    private func sample() {
        do {
            usage = try sampler.refresh()
        } catch {
            usage = nil
        }
        updateButtonTitle()
    }

    private func updateButtonTitle() {
        statusItem?.button?.title = CPUUsageDisplay.buttonTitle(for: usage)
    }
}
