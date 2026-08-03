@testable import MacPulse
import XCTest

private final class FakeLoginItemManager: LoginItemManaging {
    var isEnabled: Bool
    var registerError: Error?
    var unregisterError: Error?
    var updatesStateOnRegister = true
    private(set) var registerCallCount = 0
    private(set) var unregisterCallCount = 0

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func register() throws {
        registerCallCount += 1
        if let registerError { throw registerError }
        if updatesStateOnRegister {
            isEnabled = true
        }
    }

    func unregister() throws {
        unregisterCallCount += 1
        if let unregisterError { throw unregisterError }
        isEnabled = false
    }
}

final class LoginItemModelTests: XCTestCase {
    private struct SomeError: Error {}

    func testInitialStateReflectsManager() {
        XCTAssertTrue(LoginItemModel(manager: FakeLoginItemManager(isEnabled: true)).isEnabled)
        XCTAssertFalse(LoginItemModel(manager: FakeLoginItemManager(isEnabled: false)).isEnabled)
    }

    func testEnablingRegistersAndUpdatesState() {
        let manager = FakeLoginItemManager(isEnabled: false)
        let model = LoginItemModel(manager: manager)

        XCTAssertTrue(model.setEnabled(true))

        XCTAssertEqual(manager.registerCallCount, 1)
        XCTAssertEqual(manager.unregisterCallCount, 0)
        XCTAssertTrue(model.isEnabled)
        XCTAssertNil(model.error)
    }

    func testDisablingUnregistersAndUpdatesState() {
        let manager = FakeLoginItemManager(isEnabled: true)
        let model = LoginItemModel(manager: manager)

        XCTAssertTrue(model.setEnabled(false))

        XCTAssertEqual(manager.unregisterCallCount, 1)
        XCTAssertEqual(manager.registerCallCount, 0)
        XCTAssertFalse(model.isEnabled)
        XCTAssertNil(model.error)
    }

    func testRegisterFailureKeepsStateAndReportsError() {
        let manager = FakeLoginItemManager(isEnabled: false)
        manager.registerError = SomeError()
        let model = LoginItemModel(manager: manager)

        XCTAssertFalse(model.setEnabled(true))

        XCTAssertFalse(model.isEnabled)
        XCTAssertEqual(model.error, .registerFailed)
    }

    func testUnregisterFailureKeepsStateAndReportsError() {
        let manager = FakeLoginItemManager(isEnabled: true)
        manager.unregisterError = SomeError()
        let model = LoginItemModel(manager: manager)

        XCTAssertFalse(model.setEnabled(false))

        XCTAssertTrue(model.isEnabled)
        XCTAssertEqual(model.error, .unregisterFailed)
    }

    func testSuccessfulChangeClearsPreviousError() {
        let manager = FakeLoginItemManager(isEnabled: false)
        manager.registerError = SomeError()
        let model = LoginItemModel(manager: manager)
        model.setEnabled(true)
        XCTAssertEqual(model.error, .registerFailed)

        manager.registerError = nil
        XCTAssertTrue(model.setEnabled(true))

        XCTAssertNil(model.error)
    }

    func testStateReflectsManagerAfterSuccessfulChange() {
        let manager = FakeLoginItemManager(isEnabled: false)
        manager.updatesStateOnRegister = false
        let model = LoginItemModel(manager: manager)

        XCTAssertTrue(model.setEnabled(true))

        XCTAssertEqual(manager.registerCallCount, 1)
        XCTAssertFalse(model.isEnabled)
        XCTAssertNil(model.error)
    }

    func testRefreshReconcilesStateAndClearsError() {
        let manager = FakeLoginItemManager(isEnabled: false)
        manager.registerError = SomeError()
        let model = LoginItemModel(manager: manager)
        model.setEnabled(true)
        XCTAssertEqual(model.error, .registerFailed)

        manager.registerError = nil
        manager.isEnabled = true
        model.refresh()

        XCTAssertTrue(model.isEnabled)
        XCTAssertNil(model.error)
    }
}
