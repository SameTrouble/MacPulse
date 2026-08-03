import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case zhHans = "zh-Hans"
    case english = "en"

    var id: String { rawValue }

    var displayNameKey: LocalizationKey {
        switch self {
        case .system:
            .languageSystem
        case .zhHans:
            .languageChinese
        case .english:
            .languageEnglish
        }
    }
}
