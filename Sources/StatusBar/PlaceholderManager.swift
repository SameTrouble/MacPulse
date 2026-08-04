import AppKit
import Foundation

final class PlaceholderManager {
    private let registry: MetricRegistry
    private let localization: LocalizationProviding
    private let onOpenPreferences: () -> Void
    private var controllers: [PlaceholderController] = []

    init(registry: MetricRegistry, localization: LocalizationProviding, onOpenPreferences: @escaping () -> Void) {
        self.registry = registry
        self.localization = localization
        self.onOpenPreferences = onOpenPreferences
    }

    func apply(_ configuration: AppConfiguration) throws {
        let errors = configuration.validationErrors(against: registry)
        guard errors.isEmpty else { throw InvalidConfigurationError(errors: errors) }

        for controller in controllers {
            controller.stop()
        }
        controllers = configuration.placeholders.map { placeholder in
            PlaceholderController(
                placeholder: placeholder,
                configuration: configuration,
                registry: registry,
                localization: localization,
                onOpenPreferences: onOpenPreferences
            )
        }
        for controller in controllers {
            controller.start()
        }
    }

    func refreshDisplays() {
        for controller in controllers {
            controller.refreshDisplay()
        }
    }
}
