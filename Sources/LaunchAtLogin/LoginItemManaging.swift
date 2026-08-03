import Foundation
import ServiceManagement

protocol LoginItemManaging {
    var isEnabled: Bool { get }
    func register() throws
    func unregister() throws
}

struct SMAppServiceLoginItemManager: LoginItemManaging {
    private let service: SMAppService = .mainApp

    var isEnabled: Bool {
        service.status == .enabled
    }

    func register() throws {
        try service.register()
    }

    func unregister() throws {
        try service.unregister()
    }
}
