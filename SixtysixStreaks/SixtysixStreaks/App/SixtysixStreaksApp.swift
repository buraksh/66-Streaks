import SwiftUI
import SwiftData

@main
struct SixtyixStreaksApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appThemeMode") private var appThemeMode = "system"

    var body: some Scene {
        WindowGroup {
            ContentView(hasCompletedOnboarding: $hasCompletedOnboarding)
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
