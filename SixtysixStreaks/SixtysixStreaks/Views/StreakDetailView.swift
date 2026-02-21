import SwiftUI
import SwiftData

struct StreakDetailView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang
    @Query private var allHabits: [Habit]

    @State private var showResetConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false

    private var colors: AdaptiveColors {
        AdaptiveColors(colorScheme: colorScheme)
    }

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        heroSection
                        statsGrid
                        journeyMap
                        
                        Button {
                            showEditSheet = true
                        } label: {
                            Text(lang.localized("detail.edit"))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(colors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(colors.card)
                                .clipShape(.rect(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colors.cardBorder, lineWidth: 1)
                                )
                        }
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(colors.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            Label(lang.localized("detail.reset_progress"), systemImage: "arrow.counterclockwise")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label(lang.localized("detail.delete_habit"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(colors.textSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            CreateHabitView(isOnboarding: false, editingHabit: habit)
        }
        .alert(lang.localized("detail.reset_streak"), isPresented: $showResetConfirmation) {
            Button(lang.localized("detail.cancel"), role: .cancel) {}
            Button(lang.localized("detail.reset"), role: .destructive) {
                withAnimation(.easeInOut) {
                    habit.resetStreak()
                }
            }
        } message: {
            Text(lang.localized("detail.reset_message"))
        }
        .alert(lang.localized("detail.delete_title", habit.title), isPresented: $showDeleteConfirmation) {
            Button(lang.localized("detail.cancel"), role: .cancel) {}
            Button(lang.localized("detail.delete"), role: .destructive) {
                NotificationManager.shared.cancelNotifications(for: habit)
                modelContext.delete(habit)
                dismiss()
            }
        } message: {
            Text(lang.localized("detail.delete_message"))
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 8) {
            Image(systemName: habit.iconName)
                .font(.system(size: 40))
                .foregroundStyle(habit.habitColor)
                .padding(.bottom, 8)

            Text(habit.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(statusMessage)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            statCard(
                title: lang.localized("detail.current_streak"),
                value: "\(habit.currentStreak)",
                unit: lang.localized("detail.days"),
                icon: "flame.fill",
                color: habit.habitColor
            )
            
            statCard(
                title: lang.localized("detail.days_left"),
                value: "\(max(0, 66 - habit.currentStreak))",
                unit: lang.localized("detail.days"),
                icon: "flag.checkered",
                color: colors.textSecondary
            )
        }
    }
    
    private func statCard(title: String, value: String, unit: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(colors.textPrimary)
                    .contentTransition(.numericText())
                
                Text(unit)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colors.textSecondary)
            }
            
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(colors.textSecondary.opacity(0.8))
                .padding(.top, 4)
        }
        .padding(16)
        .background(colors.card)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Journey Map
    private var journeyMap: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(lang.localized("detail.journey_title"))
                    .font(.headline)
                    .foregroundStyle(colors.textPrimary)
                
                Spacer()
                
                Text("\(habit.progressPercentage)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(habit.habitColor)
            }
            .padding(.horizontal, 4)
            
            StreakGridView(completedDays: habit.currentStreak, totalDays: 66, filledColor: habit.habitColor)
                .padding(16)
                .background(colors.card)
                .clipShape(.rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colors.cardBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Helpers
    private var statusMessage: String {
        switch habit.currentStreak {
        case 0:
            return lang.localized("detail.status_start")
        case 1...2:
            return lang.localized("detail.status_great")
        case 3...10:
            return lang.localized("detail.status_momentum")
        case 11...30:
            return lang.localized("detail.status_consistency")
        case 31...65:
            return lang.localized("detail.status_almost")
        default:
            return lang.localized("detail.status_formed")
        }
    }
    
    private func triggerNotificationRefresh() {
        NotificationManager.shared.scheduleConsolidatedEmergencyReminder(activeHabits: allHabits)
    }
}

#Preview {
    let habit = Habit(title: "Gym", iconName: "dumbbell.fill", colorHex: "8B5CF6", reminderTime: Date())
    habit.currentStreak = 40

    return StreakDetailView(habit: habit)
        .modelContainer(for: Habit.self, inMemory: true)
        .environment(LanguageManager.shared)
}
