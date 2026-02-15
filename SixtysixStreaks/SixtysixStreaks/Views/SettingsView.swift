import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
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
                        themePicker
                    } header: {
                        Text("Appearance")
                    }

                    Section {
                        homeLayoutPicker
                    } header: {
                        Text("Streak View")
                    }

                    Section {
                        legalRow(icon: "lock.shield.fill", title: "Privacy Policy") {
                            showPrivacy = true
                        }
                        legalRow(icon: "doc.text.fill", title: "Terms of Service") {
                            showTerms = true
                        }
                    } header: {
                        Text("Legal")
                    }

                    Section {
                        HStack {
                            Text("Version")
                                .foregroundColor(colors.textPrimary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(colors.textSecondary)
                        }
                    } header: {
                        Text("About")
                    }

                    #if DEBUG
                    Section {
                        debugRow(icon: "dice.fill", title: "Add Random Data", color: .orange) {
                            addRandomData()
                        }
                        debugRow(icon: "clock.arrow.circlepath", title: "Clear Today's Data", color: AppTheme.accentBlue) {
                            clearTodaysData()
                        }
                        debugRow(icon: "trash.fill", title: "Erase All Data", color: AppTheme.dangerRed) {
                            showEraseAlert = true
                        }
                        debugRow(icon: "arrow.counterclockwise", title: "Restart Onboarding", color: .purple) {
                            restartOnboarding()
                        }
                    } header: {
                        Text("Developer")
                    }
                    #endif
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPrivacy) {
                InAppWebView(
                    title: "Privacy Policy",
                    url: URL(string: "https://driftbreath.com/privacy")!
                )
            }
            .sheet(isPresented: $showTerms) {
                InAppWebView(
                    title: "Terms of Service",
                    url: URL(string: "https://driftbreath.com/terms")!
                )
            }
            .alert("Erase All Data?", isPresented: $showEraseAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Erase Everything", role: .destructive) {
                    eraseAllData()
                }
            } message: {
                Text("This will permanently delete all habits and progress. This cannot be undone.")
            }
            .preferredColorScheme(resolvedColorScheme)
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
                        .foregroundColor(AppTheme.accentBlue)
                        .frame(width: 24)

                    Text(style.label)
                        .foregroundColor(colors.textPrimary)

                    Spacer()

                    if cardViewStyle == style.rawValue {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppTheme.accentBlue)
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
                    .foregroundColor(AppTheme.accentBlue)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(colors.textSecondary)
            }
        }
    }

    // MARK: - Debug Row
    private func debugRow(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(colors.textPrimary)
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

        for sample in sampleHabits {
            let reminderDate = calendar.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
            let habit = Habit(
                title: sample.0,
                iconName: sample.1,
                colorHex: sample.2,
                reminderTime: reminderDate
            )

            let randomDays = Int.random(in: 8...40)
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

    // MARK: - Theme Picker
    private var themePicker: some View {
        ForEach(ThemeOption.allCases, id: \.self) { option in
            Button {
                appThemeMode = option.rawValue
            } label: {
                HStack {
                    Image(systemName: option.icon)
                        .foregroundColor(AppTheme.accentBlue)
                        .frame(width: 24)

                    Text(option.label)
                        .foregroundColor(colors.textPrimary)

                    Spacer()

                    if appThemeMode == option.rawValue {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppTheme.accentBlue)
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
}

enum ThemeOption: String, CaseIterable {
    case system
    case light
    case dark

    var label: String {
        switch self {
        case .system: return "System Default"
        case .light: return "Light Mode"
        case .dark: return "Dark Mode"
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
