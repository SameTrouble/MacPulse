import AppKit

final class StatusBarController {
    private var statusItem: NSStatusItem?

    func start() {
        guard statusItem == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "MacPulse"
        statusItem = item
    }
}
