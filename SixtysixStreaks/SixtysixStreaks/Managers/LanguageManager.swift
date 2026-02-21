import SwiftUI

@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    static let supportedLanguages: [(code: String, name: String)] = [
        ("en", "English"),
        ("tr", "Türkçe")
    ]

    var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
            updateBundle()
        }
    }

    private(set) var bundle: Bundle = .main

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "appLanguage") {
            self.currentLanguage = saved
        } else {
            // Auto-detect on first launch
            let deviceLang = Locale.current.language.languageCode?.identifier ?? "en"
            let supportedCodes = Self.supportedLanguages.map(\.code)
            let detected = supportedCodes.contains(deviceLang) ? deviceLang : "en"
            self.currentLanguage = detected
            UserDefaults.standard.set(detected, forKey: "appLanguage")
        }
        updateBundle()
    }

    func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: key, table: nil)
    }

    func localized(_ key: String, _ args: CVarArg...) -> String {
        let format = bundle.localizedString(forKey: key, value: key, table: nil)
        return String(format: format, arguments: args)
    }

    private func updateBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = .main
        }
    }
}
