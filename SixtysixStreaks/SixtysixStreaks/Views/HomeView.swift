import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
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
                                HabitCardView(habit: habit) {
                                    selectedHabit = habit
                                }
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
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(colors.textSecondary)
            }

            Spacer()

            Text("66 Streaks")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(colors.textPrimary)

            Spacer()

            if habits.count < 10 {
                Button {
                    showCreateHabit = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
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

            Text("No active streaks")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(colors.textPrimary)

            Text("Start your first 66-day challenge")
                .font(.subheadline)
                .foregroundColor(colors.textSecondary)

            Button {
                showCreateHabit = true
            } label: {
                Text("Create Streak")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AppTheme.accentBlue)
                    .cornerRadius(14)
            }
            .padding(.top, 8)
        }
    }

    private var footerSection: some View {
        VStack(spacing: 16) {
            Text("It takes 66 days to form a permanent habit.")
                .font(.system(size: 14))
                .foregroundColor(colors.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11))
                Text("\(habits.count) Active Journey\(habits.count == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(colors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(colors.card)
            .cornerRadius(20)
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
        .preferredColorScheme(.dark)
}
