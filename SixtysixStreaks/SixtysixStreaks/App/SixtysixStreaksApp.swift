import SwiftUI
import SwiftData

@main
struct SixtyixStreaksApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appThemeMode") private var appThemeMode = "system"
    @State private var languageManager = LanguageManager.shared

    init() {
        // Initialize NotificationManager to set the delegate
        _ = NotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .environment(languageManager)
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(for: Habit.self)
    }

    private var colorScheme: ColorScheme? {
        switch appThemeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
