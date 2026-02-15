import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private let reminderMessages = [
        "Day %d is waiting.",
        "Don't break your streak.",
        "Your streak needs you today.",
        "%d days strong. Don't stop now.",
        "One check-in. That's all it takes.",
        "You didn't come this far to quit.",
        "Protect the streak. Check in today.",
        "Day %d won't complete itself."
    ]

    private let motivationMessages = [
        "You crushed yesterday. Keep going.",
        "Consistency builds identity.",
        "Small steps, big results.",
        "You're building something powerful.",
        "Every day counts. Especially today.",
        "The chain grows stronger with you.",
        "Winners show up every single day.",
        "Your future self will thank you."
    ]

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }

    func scheduleReminder(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        let reminderId = "reminder-\(habit.id.uuidString)"

        center.removePendingNotificationRequests(withIdentifiers: [reminderId])

        let content = UNMutableNotificationContent()
        content.title = habit.title

        let dayCount = habit.currentStreak + 1
        let template = reminderMessages.randomElement() ?? "Don't break your streak."
        content.body = template.contains("%d") ? String(format: template, dayCount) : template
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: habit.reminderTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: reminderId, content: content, trigger: trigger)

        center.add(request)
    }

    func scheduleMorningMotivation(for habit: Habit) {
        guard habit.morningMotivationEnabled else { return }

        let center = UNUserNotificationCenter.current()
        let motivationId = "motivation-\(habit.id.uuidString)"

        center.removePendingNotificationRequests(withIdentifiers: [motivationId])

        let content = UNMutableNotificationContent()
        content.title = habit.title
        content.body = motivationMessages.randomElement() ?? "Consistency builds identity."
        content.sound = .default

        var components = DateComponents()
        components.hour = 8
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: motivationId, content: content, trigger: trigger)

        center.add(request)
    }

    func cancelNotifications(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        let ids = [
            "reminder-\(habit.id.uuidString)",
            "motivation-\(habit.id.uuidString)"
        ]
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func rescheduleAll(habits: [Habit]) {
        for habit in habits where habit.habitStatus == .active {
            scheduleReminder(for: habit)
            scheduleMorningMotivation(for: habit)
        }
    }
}
