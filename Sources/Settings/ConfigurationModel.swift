import Foundation
import Observation

@Observable
final class ConfigurationModel {
    var draft: AppConfiguration

    var onCommit: ((AppConfiguration) -> Void)?

    private(set) var committed: AppConfiguration

    private let registry: MetricRegistry
    private let store: ConfigurationStore

    init(registry: MetricRegistry, store: ConfigurationStore, fallback: AppConfiguration) {
        self.registry = registry
        self.store = store
        let stored = store.load()
        let committed = stored.map { configuration in
            configuration.validationErrors(against: registry).isEmpty ? configuration : fallback
        } ?? fallback
        self.committed = committed
        draft = committed
    }

    var isDirty: Bool {
        draft != committed
    }

    var validationErrors: [ConfigurationValidationError] {
        draft.validationErrors(against: registry)
    }

    @discardableResult
    func commit() -> Bool {
        guard validationErrors.isEmpty else { return false }
        committed = draft
        try? store.save(committed)
        onCommit?(committed)
        return true
    }

    func revert() {
        draft = committed
    }
}
