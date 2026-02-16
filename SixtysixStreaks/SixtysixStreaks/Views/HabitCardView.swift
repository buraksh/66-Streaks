import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Bindable var habit: Habit
    var onCardTapped: (() -> Void)? = nil
    var onCheckInChange: (() -> Void)? = nil
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("cardViewStyle") private var cardViewStyle = "progressBar"
    @State private var animateCheckIn = false
    @State private var dayPulse = false

    private let checkIconSize: CGFloat = 36

    private var colors: AdaptiveColors {
        AdaptiveColors(colorScheme: colorScheme)
    }

    private var isCheckedState: Bool {
        habit.isCompletedToday || habit.isFullyCompleted
    }

    private var actionButtonColor: Color {
        if habit.isFullyCompleted { return AppTheme.successGreen }
        if habit.isCompletedToday { return AppTheme.successGreen }
        return habit.habitColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Top Row
            topRow
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 12)

            // MARK: - Progress Section
            if cardViewStyle == "grid" {
                gridProgress
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            } else {
                barProgress
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }
        }
        .background(colors.card)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colors.cardBorder, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onCardTapped?()
        }
    }

    // MARK: - Top Row
    private var topRow: some View {
        HStack(spacing: 12) {
            // Icon
            iconView

            // Title + Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 0) {
                    Text("Day ")
                        .font(.system(size: 13))
                        .foregroundColor(colors.textSecondary)
                    Text("\(habit.currentStreak)")
                        .font(.system(size: 13, weight: dayPulse ? .bold : .regular))
                        .foregroundColor(dayPulse ? habit.habitColor : colors.textSecondary)
                        .scaleEffect(dayPulse ? 1.4 : 1.0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: dayPulse)
                    Text(" · \(habit.progressPercentage)%")
                        .font(.system(size: 13))
                        .foregroundColor(colors.textSecondary)
                }
            }

            Spacer()

            // Action buttons
            HStack(spacing: 8) {
                checkInButton
            }
        }
    }

    // MARK: - Icon
    private var iconView: some View {
        Image(systemName: habit.iconName)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(habit.habitColor)
            .frame(width: 36, height: 36)
            .background(habit.habitColor.opacity(colorScheme == .dark ? 0.2 : 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Check-In Button
    private var checkInButton: some View {
        Image(systemName: isCheckedState ? "checkmark" : "flame")
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(isCheckedState ? .white : habit.habitColor)
            .frame(width: checkIconSize, height: checkIconSize)
            .background(isCheckedState ? actionButtonColor : habit.habitColor.opacity(colorScheme == .dark ? 0.2 : 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(animateCheckIn ? 1.2 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: animateCheckIn)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                guard !habit.isFullyCompleted else { return }
                if habit.isCompletedToday {
                    habit.undoCheckIn()
                    NotificationManager.shared.scheduleReminder(for: habit)
                    triggerAnimation()
                    onCheckInChange?()
                } else {
                    habit.checkIn()
                    NotificationManager.shared.scheduleReminder(for: habit)
                    triggerAnimation()
                    onCheckInChange?()
                }
            }
    }

    // MARK: - Progress Bar
    private var barProgress: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 6)
                    .fill(colors.gridEmptyCard)
                    .frame(height: 12)

                // Fill
                RoundedRectangle(cornerRadius: 6)
                    .fill(habit.habitColor)
                    .frame(width: max(0, geo.size.width * habit.progressFraction), height: 12)
            }
        }
        .frame(height: 12)
    }

    // MARK: - Grid Progress
    private var gridProgress: some View {
        StreakGridView(
            completedDays: habit.currentStreak,
            totalDays: 66,
            filledColor: habit.habitColor
        )
    }

    // MARK: - Animation
    private func triggerAnimation() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        withAnimation {
            animateCheckIn = true
            dayPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation {
                animateCheckIn = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                dayPulse = false
            }
        }
    }
}

// MARK: - Previews

#Preview("Progress Bar - Dark") {
    let h1 = Habit(title: "Read", iconName: "book.fill", colorHex: "10B981", reminderTime: Date())
    h1.currentStreak = 23
    h1.lastCheckInDate = Date()

    let h2 = Habit(title: "Workout", iconName: "dumbbell.fill", colorHex: "8B5CF6", reminderTime: Date())
    h2.currentStreak = 58
    h2.lastCheckInDate = Date()

    let h3 = Habit(title: "Coding", iconName: "chevron.left.forwardslash.chevron.right", colorHex: "F59E0B", reminderTime: Date())
    h3.currentStreak = 42
    h3.chapter = 2
    h3.lastCheckInDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())

    return VStack(spacing: 12) {
        HabitCardView(habit: h1)
        HabitCardView(habit: h2)
        HabitCardView(habit: h3)
    }
    .padding(16)
    .background(AppTheme.darkBackground)
    .modelContainer(for: Habit.self, inMemory: true)
    .preferredColorScheme(.dark)
}

#Preview("Grid - Dark") {
    let h1 = Habit(title: "Read", iconName: "book.fill", colorHex: "10B981", reminderTime: Date())
    h1.currentStreak = 23
    h1.lastCheckInDate = Date()

    let h2 = Habit(title: "Workout", iconName: "dumbbell.fill", colorHex: "8B5CF6", reminderTime: Date())
    h2.currentStreak = 58
    h2.lastCheckInDate = Date()

    return VStack(spacing: 12) {
        HabitCardView(habit: h1)
        HabitCardView(habit: h2)
    }
    .padding(16)
    .background(AppTheme.darkBackground)
    .modelContainer(for: Habit.self, inMemory: true)
    .preferredColorScheme(.dark)
    .onAppear {
        UserDefaults.standard.set("grid", forKey: "cardViewStyle")
    }
}

#Preview("Progress Bar - Light") {
    let h1 = Habit(title: "Meditate", iconName: "figure.mind.and.body", colorHex: "06B6D4", reminderTime: Date())
    h1.currentStreak = 15
    h1.lastCheckInDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())

    return HabitCardView(habit: h1)
        .padding(16)
        .background(AppTheme.lightBackground)
        .modelContainer(for: Habit.self, inMemory: true)
        .preferredColorScheme(.light)
}
