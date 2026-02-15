import Foundation
import SwiftData
import SwiftUI

enum HabitStatus: String, Codable {
    case active
    case broken
    case completed
}

struct Reminder: Codable, Identifiable, Hashable {
    var id = UUID()
    var time: Date
    var isEnabled: Bool
}

@Model
final class Habit {
    var id: UUID
    var title: String
    var emoji: String = ""
    var iconName: String = "flame.fill"
    var colorHex: String = "10B981"
    var chapter: Int = 1
    var startDate: Date
    var currentStreak: Int
    var lastCheckInDate: Date?
    
    // Future-proof: Support multiple reminders
    var reminders: [Reminder] = []
    
    var morningMotivationEnabled: Bool
    var status: String // "active", "broken", "completed"
    var completedDates: [Date]

    init(
        title: String,
        iconName: String = "flame.fill",
        colorHex: String = "10B981",
        reminderTime: Date,
        reminderEnabled: Bool = true,
        checkInWindowStart: Int = 6,
        checkInWindowEnd: Int = 23,
        morningMotivationEnabled: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.emoji = ""
        self.iconName = iconName
        self.colorHex = colorHex
        self.chapter = 1
        self.startDate = Calendar.current.startOfDay(for: Date())
        self.currentStreak = 0
        self.lastCheckInDate = nil
        
        // Initialize with single reminder
        self.reminders = [Reminder(time: reminderTime, isEnabled: reminderEnabled)]
        
        self.morningMotivationEnabled = morningMotivationEnabled
        self.status = HabitStatus.active.rawValue
        self.completedDates = []
    }

    // MARK: - Computed Properties
    
    // Backward compatibility for single-reminder UI
    var reminderTime: Date {
        get {
            if reminders.isEmpty { return Date() }
            return reminders[0].time
        }
        set {
            if reminders.isEmpty {
                reminders.append(Reminder(time: newValue, isEnabled: true))
            } else {
                reminders[0].time = newValue
            }
        }
    }
    
    var reminderEnabled: Bool {
        get {
            if reminders.isEmpty { return false }
            return reminders[0].isEnabled
        }
        set {
            if reminders.isEmpty {
                reminders.append(Reminder(time: Date(), isEnabled: newValue))
            } else {
                reminders[0].isEnabled = newValue
            }
        }
    }

    var habitColor: Color {
        Color(hex: colorHex)
    }

    var habitStatus: HabitStatus {
        get { HabitStatus(rawValue: status) ?? .active }
        set { status = newValue.rawValue }
    }

    var isCompletedToday: Bool {
        guard let lastDate = lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }

    var progressPercentage: Int {
        guard currentStreak > 0 else { return 0 }
        return Int((Double(currentStreak) / 66.0) * 100)
    }

    var progressFraction: Double {
        min(Double(currentStreak) / 66.0, 1.0)
    }

    var isFullyCompleted: Bool {
        currentStreak >= 66
    }

    // MARK: - Actions

    func checkIn() {
        guard !isCompletedToday else { return }
        let now = Date()
        lastCheckInDate = now
        currentStreak += 1
        completedDates.append(Calendar.current.startOfDay(for: now))

        if currentStreak >= 66 {
            habitStatus = .completed
        }
    }

    func undoCheckIn() {
        guard isCompletedToday else { return }
        currentStreak = max(0, currentStreak - 1)

        let today = Calendar.current.startOfDay(for: Date())
        completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }

        if let previousDate = completedDates.last {
            lastCheckInDate = previousDate
        } else {
            lastCheckInDate = nil
        }

        if habitStatus == .completed {
            habitStatus = .active
        }
    }

    func validateStreak() {
        guard habitStatus == .active else { return }
        guard let lastDate = lastCheckInDate else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)

        if lastDay < calendar.date(byAdding: .day, value: -1, to: today)! {
            resetStreak()
        }
    }

    func resetStreak() {
        chapter += 1
        currentStreak = 0
        completedDates = []
        startDate = Calendar.current.startOfDay(for: Date())
        lastCheckInDate = nil
        habitStatus = .active
    }


}
