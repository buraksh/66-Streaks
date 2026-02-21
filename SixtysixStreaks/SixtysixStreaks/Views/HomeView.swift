import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @Environment(LanguageManager.self) private var lang
    @Query(sort: \Habit.startDate, order: .forward) private var habits: [Habit]
    @State private var showCreateHabit = false
    @State private var showSettings = false
    @State private var selectedHabit: Habit?

    private var colors: AdaptiveColors {
        AdaptiveColors(colorScheme: colorScheme)
    }

    private var activeHabits: [Habit] {
        habits.filter { $0.habitStatus != .broken || $0.currentStreak == 0 }
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            
            if habits.isEmpty {
                Spacer()
                emptyState
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        LazyVStack(spacing: 12) {
                            ForEach(habits) { habit in
                                HabitCardView(
                                    habit: habit,
                                    onCardTapped: {
                                        selectedHabit = habit
                                    },
                                    onCheckInChange: {
                                        // Refresh consolidated reminder immediately
                                        NotificationManager.shared.scheduleConsolidatedEmergencyReminder(activeHabits: habits)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        footerSection
                            .padding(.top, 32)
                            .padding(.bottom, 100)
                    }
                }
            }
        }
        .background(colors.background.ignoresSafeArea())
        .sheet(isPresented: $showCreateHabit) {
            CreateHabitView(isOnboarding: false)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(item: $selectedHabit) { habit in
            StreakDetailView(habit: habit)
        }
        .onAppear {
            validateAllStreaks()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                validateAllStreaks()
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(colors.textSecondary)
            }

            Spacer()

            Text(lang.localized("home.title"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(colors.textPrimary)

            Spacer()

            if habits.count < 4 {
                Button {
                    showCreateHabit = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.ctaGradient)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.accentBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            } else {
                Color.clear.frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("🔥")
                .font(.system(size: 60))

            Text(lang.localized("home.empty_title"))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(colors.textPrimary)

            Text(lang.localized("home.empty_subtitle"))
                .font(.subheadline)
                .foregroundStyle(colors.textSecondary)

            Button {
                showCreateHabit = true
            } label: {
                Text(lang.localized("home.create_streak"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AppTheme.ctaGradient)
                    .clipShape(.rect(cornerRadius: 14))
            }
            .padding(.top, 8)
        }
    }

    private var footerSection: some View {
        VStack(spacing: 16) {
            Text(lang.localized("home.footer"))
                .font(.system(size: 14))
                .foregroundStyle(colors.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11))
                let journeyKey = habits.count == 1 ? "home.active_journey_singular" : "home.active_journey_plural"
                Text(lang.localized(journeyKey, habits.count))
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(colors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(colors.card)
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(colors.cardBorder, lineWidth: 1)
            )
        }
    }

    private func validateAllStreaks() {
        for habit in habits {
            habit.validateStreak()
        }
        NotificationManager.shared.rescheduleAll(habits: habits)
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    let completed = Habit(title: "Meditation", iconName: "figure.mind.and.body", colorHex: "06B6D4", reminderTime: Date())
    completed.currentStreak = 66
    completed.lastCheckInDate = Date()
    completed.status = HabitStatus.completed.rawValue
    container.mainContext.insert(completed)

    let active = Habit(title: "Dead Hang", iconName: "dumbbell.fill", colorHex: "8B5CF6", reminderTime: Date())
    active.currentStreak = 23
    active.lastCheckInDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    container.mainContext.insert(active)

    return HomeView()
        .modelContainer(container)
        .environment(LanguageManager.shared)
        .preferredColorScheme(.dark)
}
