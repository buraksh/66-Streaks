import SwiftUI
import SwiftData

struct StreakDetailView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Query private var allHabits: [Habit]

    @State private var showResetConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false

    private var colors: AdaptiveColors {
        AdaptiveColors(colorScheme: colorScheme)
    }
    
    // ... (rest of body until Delete action) ...



    // ... (rest of view) ...
    
    // Grid columns for the main layout

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
                            Text("Edit")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(colors.textPrimary) // Make it look active
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(colors.card)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colors.cardBorder, lineWidth: 1) // Add border for better definition
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
                            .font(.system(size: 18, weight: .semibold)) // Match HomeView style
                            .foregroundColor(colors.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            Label("Reset Progress", systemImage: "arrow.counterclockwise")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Habit", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .semibold)) // Match HomeView style
                            .foregroundColor(colors.textSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            CreateHabitView(isOnboarding: false, editingHabit: habit)
        }
        .alert("Reset streak?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                withAnimation(.easeInOut) {
                    habit.resetStreak()
                }
            }
        } message: {
            Text("You will start again from Day 0.\nThis cannot be undone.")
        }
        .alert("Delete \"\(habit.title)\"?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                NotificationManager.shared.cancelNotifications(for: habit)
                modelContext.delete(habit)
                dismiss()
            }
        } message: {
            Text("All progress will be removed permanently.")
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 8) {
            Image(systemName: habit.iconName)
                .font(.system(size: 40))
                .foregroundColor(habit.habitColor)
                .padding(.bottom, 8)

            Text(habit.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(statusMessage)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            // Current Streak Card
            statCard(
                title: "Current Streak",
                value: "\(habit.currentStreak)",
                unit: "Days",
                icon: "flame.fill",
                color: habit.habitColor
            )
            
            // Days Left Card
            statCard(
                title: "Days Left",
                value: "\(max(0, 66 - habit.currentStreak))",
                unit: "Days",
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
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(colors.textPrimary)
                    .contentTransition(.numericText())
                
                Text(unit)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(colors.textSecondary)
            }
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(colors.textSecondary.opacity(0.8))
                .padding(.top, 4)
        }
        .padding(16)
        .background(colors.card)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Journey Map
    private var journeyMap: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("66 Day Journey")
                    .font(.headline)
                    .foregroundColor(colors.textPrimary)
                
                Spacer()
                
                Text("\(habit.progressPercentage)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(habit.habitColor)
            }
            .padding(.horizontal, 4)
            
            StreakGridView(completedDays: habit.currentStreak, totalDays: 66, filledColor: habit.habitColor)
                .padding(16)
                .background(colors.card)
                .cornerRadius(20)
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
            return "Start your journey today"
        case 1...2:
            return "Great start!"
        case 3...10:
            return "Building momentum"
        case 11...30:
            return "Consistency is key"
        case 31...65:
            return "Almost automatic"
        default:
            return "Habit formed!"
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
}
