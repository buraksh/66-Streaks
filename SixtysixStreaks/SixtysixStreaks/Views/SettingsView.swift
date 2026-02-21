import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var lang
    @AppStorage("appThemeMode") private var appThemeMode = "system"
    @AppStorage("cardViewStyle") private var cardViewStyle = "progressBar"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @Query private var habits: [Habit]

    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showEraseAlert = false

    private var colors: AdaptiveColors {
        AdaptiveColors(colorScheme: colorScheme)
    }

    private var resolvedColorScheme: ColorScheme? {
        switch appThemeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()

                List {
                    Section {
                        languagePicker
                    } header: {
                        Text(lang.localized("settings.language"))
                    } footer: {
                        Text(lang.localized("settings.language_note"))
                    }

                    Section {
                        themePicker
                    } header: {
                        Text(lang.localized("settings.appearance"))
                    }

                    Section {
                        homeLayoutPicker
                    } header: {
                        Text(lang.localized("settings.streak_view"))
                    }

                    Section {
                        legalRow(icon: "lock.shield.fill", title: lang.localized("settings.privacy_policy")) {
                            showPrivacy = true
                        }
                        legalRow(icon: "doc.text.fill", title: lang.localized("settings.terms_of_service")) {
                            showTerms = true
                        }
                    } header: {
                        Text(lang.localized("settings.legal"))
                    }

                    Section {
                        HStack {
                            Text(lang.localized("settings.version"))
                                .foregroundStyle(colors.textPrimary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(colors.textSecondary)
                        }
                    } header: {
                        Text(lang.localized("settings.about"))
                    }

                    Section {
                        settingsActionRow(icon: "trash.fill", title: lang.localized("settings.erase_all_data"), color: AppTheme.dangerRed) {
                            showEraseAlert = true
                        }
                    } header: {
                        Text(lang.localized("settings.data"))
                    }

                    #if DEBUG
                    Section {
                        settingsActionRow(icon: "dice.fill", title: "Add Random Data", color: .orange) {
                            addRandomData()
                        }
                        settingsActionRow(icon: "clock.arrow.circlepath", title: "Clear Today's Data", color: AppTheme.accentBlue) {
                            clearTodaysData()
                        }
                        settingsActionRow(icon: "arrow.counterclockwise", title: "Restart Onboarding", color: .purple) {
                            restartOnboarding()
                        }
                        settingsActionRow(icon: "star.bubble", title: "Reset Review State", color: .yellow) {
                            resetReviewState()
                        }
                    } header: {
                        Text("Developer")
                    }
                    #endif
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(lang.localized("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lang.localized("settings.done")) { dismiss() }
                }
            }
            .sheet(isPresented: $showPrivacy) {
                InAppWebView(
                    title: lang.localized("settings.privacy_policy"),
                    url: URL(string: "https://66-streaks.buraksahin.net/privacy/")!
                )
            }
            .sheet(isPresented: $showTerms) {
                InAppWebView(
                    title: lang.localized("settings.terms_of_service"),
                    url: URL(string: "https://66-streaks.buraksahin.net/terms")!
                )
            }
            .alert(lang.localized("settings.erase_alert_title"), isPresented: $showEraseAlert) {
                Button(lang.localized("settings.cancel"), role: .cancel) {}
                Button(lang.localized("settings.erase_everything"), role: .destructive) {
                    eraseAllData()
                }
            } message: {
                Text(lang.localized("settings.erase_alert_message"))
            }
            .preferredColorScheme(resolvedColorScheme)
        }
    }

    // MARK: - Language Picker
    private var languagePicker: some View {
        ForEach(LanguageManager.supportedLanguages, id: \.code) { language in
            Button {
                lang.currentLanguage = language.code
            } label: {
                HStack {
                    Text(language.name)
                        .foregroundStyle(colors.textPrimary)

                    Spacer()

                    if lang.currentLanguage == language.code {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppTheme.accentBlue)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    // MARK: - Home Layout Picker
    private var homeLayoutPicker: some View {
        ForEach(CardViewStyle.allCases, id: \.self) { style in
            Button {
                cardViewStyle = style.rawValue
            } label: {
                HStack {
                    Image(systemName: style.icon)
                        .foregroundStyle(AppTheme.accentBlue)
                        .frame(width: 24)

                    Text(style.localizedLabel)
                        .foregroundStyle(colors.textPrimary)

                    Spacer()

                    if cardViewStyle == style.rawValue {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppTheme.accentBlue)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    // MARK: - Legal Row
    private func legalRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.accentBlue)
                    .frame(width: 24)
                Text(title)
                    .foregroundStyle(colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colors.textSecondary)
            }
        }
    }

    // MARK: - Action Row
    private func settingsActionRow(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)
                Text(title)
                    .foregroundStyle(colors.textPrimary)
                Spacer()
            }
        }
    }

    // MARK: - Debug Actions
    private func addRandomData() {
        let sampleHabits: [(String, String, String)] = [
            ("Go to the gym", "dumbbell.fill", "8B5CF6"),
            ("Read 30 minutes", "book.fill", "10B981"),
            ("Meditate", "figure.mind.and.body", "06B6D4"),
        ]

        // Erase existing first
        for habit in habits {
            NotificationManager.shared.cancelNotifications(for: habit)
            modelContext.delete(habit)
        }

        let calendar = Calendar.current

        for (index, sample) in sampleHabits.enumerated() {
            let reminderDate = calendar.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
            let habit = Habit(
                title: sample.0,
                iconName: sample.1,
                colorHex: sample.2,
                reminderTime: reminderDate
            )

            // Fixed streak days for testing: 6, 20, and 65
            let streakDays = [6, 20, 65]
            let randomDays = streakDays[index]
            
            let startDate = calendar.date(byAdding: .day, value: -randomDays, to: Date())!
            habit.startDate = calendar.startOfDay(for: startDate)
            habit.currentStreak = randomDays
            
            // Set lastCheckInDate to yesterday so they're NOT checked in today
            habit.lastCheckInDate = calendar.date(byAdding: .day, value: -1, to: Date())

            var dates: [Date] = []
            for day in 0..<randomDays {
                if let date = calendar.date(byAdding: .day, value: day, to: habit.startDate) {
                    dates.append(calendar.startOfDay(for: date))
                }
            }
            habit.completedDates = dates

            modelContext.insert(habit)
        }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    private func clearTodaysData() {
        let calendar = Calendar.current
        for habit in habits {
            if habit.isCompletedToday {
                habit.currentStreak = max(0, habit.currentStreak - 1)
                habit.completedDates = habit.completedDates.filter {
                    !calendar.isDateInToday($0)
                }
                if habit.currentStreak > 0 {
                    habit.lastCheckInDate = calendar.date(byAdding: .day, value: -1, to: Date())
                } else {
                    habit.lastCheckInDate = nil
                }
                if habit.habitStatus == .completed && habit.currentStreak < 66 {
                    habit.habitStatus = .active
                }
            }
        }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    private func eraseAllData() {
        for habit in habits {
            NotificationManager.shared.cancelNotifications(for: habit)
            modelContext.delete(habit)
        }

        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }

    private func restartOnboarding() {
        hasCompletedOnboarding = false
        dismiss()
    }

    private func resetReviewState() {
        ReviewManager.shared.resetState()
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    // MARK: - Theme Picker
    private var themePicker: some View {
        ForEach(ThemeOption.allCases, id: \.self) { option in
            Button {
                appThemeMode = option.rawValue
            } label: {
                HStack {
                    Image(systemName: option.icon)
                        .foregroundStyle(AppTheme.accentBlue)
                        .frame(width: 24)

                    Text(option.localizedLabel)
                        .foregroundStyle(colors.textPrimary)

                    Spacer()

                    if appThemeMode == option.rawValue {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppTheme.accentBlue)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Habit.self, inMemory: true)
        .environment(LanguageManager.shared)
}

enum ThemeOption: String, CaseIterable {
    case system
    case light
    case dark

    var localizedLabel: String {
        switch self {
        case .system: return LanguageManager.shared.localized("theme.system_default")
        case .light: return LanguageManager.shared.localized("theme.light_mode")
        case .dark: return LanguageManager.shared.localized("theme.dark_mode")
        }
    }

    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
