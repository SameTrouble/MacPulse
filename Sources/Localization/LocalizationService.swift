import Foundation
import Observation

protocol LocalizationProviding {
    func text(_ key: LocalizationKey) -> String
    func text(_ key: LocalizationKey, _ arguments: CVarArg...) -> String
}

protocol LanguageStoring {
    func load() -> AppLanguage?
    func save(_ language: AppLanguage)
}

struct UserDefaultsLanguageStore: LanguageStoring {
    static let key = "appLanguage"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AppLanguage? {
        defaults.string(forKey: Self.key).flatMap(AppLanguage.init(rawValue:))
    }

    func save(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: Self.key)
    }
}

@Observable
final class LocalizationService: LocalizationProviding {
    var language: AppLanguage {
        didSet {
            store.save(language)
        }
    }

    private let store: LanguageStoring
    private let systemPreferredLanguage: () -> String?

    init(
        store: LanguageStoring = UserDefaultsLanguageStore(),
        systemPreferredLanguage: @escaping () -> String? = { Locale.preferredLanguages.first }
    ) {
        self.store = store
        self.systemPreferredLanguage = systemPreferredLanguage
        language = store.load() ?? .system
    }

    func text(_ key: LocalizationKey) -> String {
        LocalizedStrings.translation(for: key, in: resolvedLanguage)
    }

    func text(_ key: LocalizationKey, _ arguments: CVarArg...) -> String {
        String(format: LocalizedStrings.translation(for: key, in: resolvedLanguage), arguments: arguments)
    }

    var resolvedLanguage: ResolvedLanguage {
        switch language {
        case .system:
            guard let preferred = systemPreferredLanguage() else { return .english }
            return preferred.hasPrefix("zh") ? .zhHans : .english
        case .zhHans:
            return .zhHans
        case .english:
            return .english
        }
    }
}
