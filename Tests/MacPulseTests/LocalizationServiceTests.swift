@testable import MacPulse
import XCTest

final class LocalizationServiceTests: XCTestCase {
    func testDefaultsToSystemLanguage() {
        let service = LocalizationService(store: InMemoryLanguageStore(), systemPreferredLanguage: { "en" })

        XCTAssertEqual(service.language, .system)
    }

    func testLoadsPersistedLanguage() {
        let store = InMemoryLanguageStore()
        store.save(.english)
        let service = LocalizationService(store: store, systemPreferredLanguage: { "zh-Hans" })

        XCTAssertEqual(service.language, .english)
    }

    func testChangingLanguagePersists() {
        let store = InMemoryLanguageStore()
        let service = LocalizationService(store: store, systemPreferredLanguage: { "en" })

        service.language = .zhHans

        XCTAssertEqual(store.stored, .zhHans)
    }

    func testSystemLanguageFollowsChineseSystem() {
        let service = localizationService(language: .system, systemPreferred: "zh-Hans")

        XCTAssertEqual(service.text(.save), "保存")
        XCTAssertEqual(service.text(.tabPlaceholders), "占位")
    }

    func testSystemLanguageFollowsEnglishSystem() {
        let service = localizationService(language: .system, systemPreferred: "en-US")

        XCTAssertEqual(service.text(.save), "Save")
        XCTAssertEqual(service.text(.tabPlaceholders), "Placeholders")
    }

    func testSystemLanguageFallsBackToEnglishWithoutPreferredLanguage() {
        let service = localizationService(language: .system, systemPreferred: nil)

        XCTAssertEqual(service.text(.save), "Save")
    }

    func testExplicitLanguageOverridesSystem() {
        let service = localizationService(language: .zhHans, systemPreferred: "en-US")

        XCTAssertEqual(service.text(.save), "保存")
        XCTAssertEqual(service.text(.menuQuit), "退出 MacPulse")
    }

    func testFormattingWithArguments() {
        let zh = localizationService(language: .zhHans)
        let en = localizationService(language: .english)

        XCTAssertEqual(zh.text(.placeholderName, 2), "占位 2")
        XCTAssertEqual(en.text(.placeholderName, 2), "Placeholder 2")
        XCTAssertEqual(zh.text(.seconds, 5), "5 秒")
        XCTAssertEqual(en.text(.seconds, 5), "5 s")
        XCTAssertEqual(zh.text(.cpuOverall, "38%"), "总体 CPU：38%")
        XCTAssertEqual(zh.text(.cpuCore, 1, "50%"), "核心 1：50%")
        XCTAssertEqual(en.text(.cpuCore, 1, "50%"), "Core 1: 50%")
    }

    func testLanguageDisplayNames() {
        let zh = localizationService(language: .zhHans)
        let en = localizationService(language: .english)

        XCTAssertEqual(zh.text(.languageSystem), "跟随系统")
        XCTAssertEqual(zh.text(.languageChinese), "中文")
        XCTAssertEqual(zh.text(.languageEnglish), "English")
        XCTAssertEqual(en.text(.languageSystem), "Follow System")
        XCTAssertEqual(en.text(.languageChinese), "中文")
        XCTAssertEqual(en.text(.languageEnglish), "English")
    }
}
