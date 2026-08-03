import Foundation
import Observation

enum LoginItemChangeError: Equatable {
    case registerFailed
    case unregisterFailed
}

@Observable
final class LoginItemModel {
    private(set) var isEnabled: Bool
    private(set) var error: LoginItemChangeError?

    private let manager: LoginItemManaging

    init(manager: LoginItemManaging) {
        self.manager = manager
        isEnabled = manager.isEnabled
    }

    @discardableResult
    func setEnabled(_ enabled: Bool) -> Bool {
        do {
            if enabled {
                try manager.register()
            } else {
                try manager.unregister()
            }
            isEnabled = manager.isEnabled
            error = nil
            return true
        } catch {
            self.error = enabled ? .registerFailed : .unregisterFailed
            return false
        }
    }

    func refresh() {
        isEnabled = manager.isEnabled
        error = nil
    }
}
