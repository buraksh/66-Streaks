import SwiftUI
import SwiftData

@main
struct SixtyixStreaksApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appThemeMode") private var appThemeMode = "system"
    @Environment(\.scenePhase) private var scenePhase
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
            }
        }
    }

    private var colorScheme: ColorScheme? {
        switch appThemeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

extension Notification.Name {
    static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
}
