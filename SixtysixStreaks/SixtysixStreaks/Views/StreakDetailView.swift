import SwiftUI
import SwiftData

struct StreakDetailView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showResetConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false

    private var colors: AdaptiveColors {
        AdaptiveColors(colorScheme: colorScheme)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    streakHeader
                    actionButtons
                    Spacer()
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(colors.textSecondary.opacity(0.6))
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
                withAnimation(.easeInOut(duration: 0.5)) {
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

    // MARK: - Streak Header
    private var streakHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: habit.iconName)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(habit.habitColor)
                .frame(width: 64, height: 64)
                .background(habit.habitColor.opacity(colorScheme == .dark ? 0.2 : 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(habit.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(colors.textPrimary)

            Text("Day \(habit.currentStreak) of 66")
                .font(.system(size: 17))
                .foregroundColor(colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(colors.card)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 0) {
            // Edit Streak
            Button {
                showEditSheet = true
            } label: {
                HStack {
                    Text("Edit Streak")
                        .font(.system(size: 17))
                        .foregroundColor(colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.textSecondary)
                }
                .padding(16)
            }

            Divider()
                .padding(.leading, 16)

            // Reset Progress
            Button {
                showResetConfirmation = true
            } label: {
                HStack {
                    Text("Reset Progress")
                        .font(.system(size: 17))
                        .foregroundColor(colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.textSecondary)
                }
                .padding(16)
            }

            Divider()

            // Delete Streak
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Text("Delete Streak")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.dangerRed)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.dangerRed.opacity(0.6))
                }
                .padding(16)
            }
        }
        .background(colors.card)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colors.cardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    let habit = Habit(title: "Gym", iconName: "dumbbell.fill", colorHex: "8B5CF6", reminderTime: Date())
    habit.currentStreak = 23

    return StreakDetailView(habit: habit)
        .modelContainer(for: Habit.self, inMemory: true)
}
