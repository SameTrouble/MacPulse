import AppKit
@testable import MacPulse
import XCTest

private final class SpyWindowFactory {
    private(set) var windows: [NSWindow] = []
    var callCount: Int { windows.count }

    func make() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        windows.append(window)
        return window
    }
}

private final class FakeLoginItemManager: LoginItemManaging {
    var isEnabled = false

    func register() throws {}

    func unregister() throws {}
}

final class SettingsWindowControllerTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = UUID().uuidString
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testFirstOpenCreatesExactlyOneWindow() {
        let spy = SpyWindowFactory()
        let controller = makeController(spy: spy)

        controller.open()

        XCTAssertEqual(spy.callCount, 1)
    }

    func testSecondOpenReusesExistingWindow() {
        let spy = SpyWindowFactory()
        let controller = makeController(spy: spy)

        controller.open()
        controller.open()

        XCTAssertEqual(spy.callCount, 1)
    }

    func testCloseClearsReferenceAndNextOpenCreatesNewWindow() {
        let spy = SpyWindowFactory()
        let controller = makeController(spy: spy)

        controller.open()
        spy.windows.first?.close()
        controller.open()

        XCTAssertEqual(spy.callCount, 2)
    }

    func testMakeWindowHasExpectedContentSize() {
        let window = SettingsWindowController.makeWindow()

        XCTAssertEqual(window.contentRect(forFrameRect: window.frame).size, NSSize(width: 700, height: 560))
    }

    func testMakeWindowIsResizable() {
        let window = SettingsWindowController.makeWindow()

        XCTAssertTrue(window.styleMask.contains(.resizable))
    }

    private func makeController(spy: SpyWindowFactory) -> SettingsWindowController {
        let registry = MetricRegistry()
        let model = ConfigurationModel(
            registry: registry,
            store: ConfigurationStore(defaults: defaults),
            fallback: AppConfiguration(placeholders: [])
        )
        return SettingsWindowController(
            model: model,
            registry: registry,
            localization: localizationService(),
            loginItem: LoginItemModel(manager: FakeLoginItemManager()),
            windowFactory: spy.make
        )
    }
}
