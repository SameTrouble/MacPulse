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
        var migrated = stored.map { $0.migratingLegacyTemperature() }
        if var configuration = migrated {
            _ = configuration.samplingInterval(for: .temperature, registry: registry)
            migrated = configuration
        }
        if let migrated, migrated != stored {
            try? store.save(migrated)
        }
        let committed = migrated.map { configuration in
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
