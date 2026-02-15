import Foundation
import UserNotifications

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

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

    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and play sound even if app is in foreground
        completionHandler([.banner, .sound])
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }

    func scheduleReminder(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        
        // Remove all previous possible reminder IDs for this habit
        // Note: Since we don't store old IDs, we'll iterate a reasonable range or just use strict ID naming.
        // For now, we clear the *specific* legacy ID and the new IDs.
        // A better approach is to cancel all by category, but we'll stick to ID generation.
        
        // Cancel legacy single ID just in case
        center.removePendingNotificationRequests(withIdentifiers: ["reminder-\(habit.id.uuidString)"])
        
        // Schedule each enabled reminder
        for fragment in habit.reminders where fragment.isEnabled {
            let reminderId = "reminder-\(habit.id.uuidString)-\(fragment.id.uuidString)"
            
            // Remove specific pending first (to update)
            center.removePendingNotificationRequests(withIdentifiers: [reminderId])
            
            let content = UNMutableNotificationContent()
            content.title = habit.title

            let dayCount = habit.currentStreak + 1
            let template = reminderMessages.randomElement() ?? "Don't break your streak."
            content.body = template.contains("%d") ? String(format: template, dayCount) : template
            content.sound = .default

            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: fragment.time)

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: reminderId, content: content, trigger: trigger)

            center.add(request)
        }
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

    private let emergencyMessages = [
        "🔥 The flame is flickering! Check in now to keep your %d-day streak alive.",
        "⚠️ Emergency: Your %d-day streak is about to go cold. Don't let it die!",
        "Don't extinguish the fire. You've burned bright for %d days. Keep it going!",
        "3 hours left to save your streak! ⏳ Day %d counts on you.",
        "It only takes one spark. ✨ Check in now to secure day %d.",
        "You're on fire! 🔥 Don't let today be the day it goes out. (%d days)",
        "Protect the flame. 🛡️ Your %d-day streak is at risk. Act now!",
        "It takes 66 days to forge a fire. You're at day %d. Don't stop now.",
        "Warning: Streak extinguishing soon. 🧯 Save your %d days of progress!",
        "The chain is %d links strong. Don't break it tonight. ⛓️🔥"
    ]

    func scheduleEmergencyReminder(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        let emergencyId = "emergency-\(habit.id.uuidString)"
        
        center.removePendingNotificationRequests(withIdentifiers: [emergencyId])

        let content = UNMutableNotificationContent()
        content.title = "⚠️ Streak Risk: \(habit.title)"
        
        let dayCount = habit.currentStreak + 1
        // If streak is 0, we can just say "Start your streak" or use a generic one, 
        // but for simplicity we'll format with dayCount (Day 1).
        let template = emergencyMessages.randomElement() ?? "You haven't checked in yet. Keep your streak alive!"
        content.body = String(format: template, dayCount)
        
        content.sound = .default

        let trigger: UNNotificationTrigger
        
        if habit.isCompletedToday {
            // If already done today, schedule a ONE-TIME reminder for TOMORROW at 9 PM.
            // This ensures we skip today (no annoyance) but catch them if they forget tomorrow.
            // If they interact with tomorrow's alert, the app opens and reschedules a repeating one.
            guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return }
            var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
            components.hour = 21
            components.minute = 0
            
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            // If not done today (or unchecked), schedule REPEATING daily at 9 PM.
            var components = DateComponents()
            components.hour = 21
            components.minute = 0
            
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        }
        
        let request = UNNotificationRequest(identifier: emergencyId, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelEmergencyReminder(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["emergency-\(habit.id.uuidString)"])
    }

    func cancelNotifications(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        
        var ids = [
            "reminder-\(habit.id.uuidString)", // Legacy single ID
            "motivation-\(habit.id.uuidString)",
            "emergency-\(habit.id.uuidString)"
        ]
        
        // Add all current reminder sub-IDs
        for fragment in habit.reminders {
            ids.append("reminder-\(habit.id.uuidString)-\(fragment.id.uuidString)")
        }
        
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func rescheduleAll(habits: [Habit]) {
        for habit in habits where habit.habitStatus == .active {
            scheduleReminder(for: habit)
            scheduleMorningMotivation(for: habit)
            scheduleEmergencyReminder(for: habit)
        }
    }
}
