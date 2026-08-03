@testable import MacPulse
import XCTest

final class LocalizedStringsTests: XCTestCase {
    func testEveryKeyHasTranslationsInBothLanguages() {
        for key in LocalizationKey.allCases {
            let zh = LocalizedStrings.translation(for: key, in: .zhHans)
            let en = LocalizedStrings.translation(for: key, in: .english)
            XCTAssertFalse(zh.isEmpty, "missing zh translation for \(key.rawValue)")
            XCTAssertFalse(en.isEmpty, "missing en translation for \(key.rawValue)")
            XCTAssertNotEqual(zh, key.rawValue, "untranslated zh key \(key.rawValue)")
            XCTAssertNotEqual(en, key.rawValue, "untranslated en key \(key.rawValue)")
        }
    }

    func testFormatPlaceholdersMatchBetweenLanguages() {
        for key in LocalizationKey.allCases {
            let zh = LocalizedStrings.translation(for: key, in: .zhHans)
            let en = LocalizedStrings.translation(for: key, in: .english)
            XCTAssertEqual(
                placeholderCount(in: zh),
                placeholderCount(in: en),
                "format placeholder count differs for \(key.rawValue)"
            )
        }
    }

    private func placeholderCount(in string: String) -> Int {
        string.components(separatedBy: "%").dropFirst().filter { part in
            guard let first = part.first else { return false }
            return "%@df".contains(first)
        }.count
    }

    func testSettingsKeysTranslateToExpectedChinese() {
        XCTAssertEqual(LocalizedStrings.translation(for: .tabPlaceholders, in: .zhHans), "占位")
        XCTAssertEqual(LocalizedStrings.translation(for: .save, in: .zhHans), "保存")
        XCTAssertEqual(LocalizedStrings.translation(for: .cancel, in: .zhHans), "取消")
    }

    func testMenuKeysTranslateToExpectedEnglish() {
        XCTAssertEqual(LocalizedStrings.translation(for: .menuPreferences, in: .english), "Preferences…")
        XCTAssertEqual(LocalizedStrings.translation(for: .menuQuit, in: .english), "Quit MacPulse")
    }
}
