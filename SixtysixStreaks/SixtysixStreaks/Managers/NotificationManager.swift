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

    // Old individual messages removed


    private let consolidatedEmergencyMessages = [
        "🔥 The flame is flickering! Complete %d habits to keep it alive.",
        "⚠️ Emergency: %d habits are still pending. Don't let them go cold!",
        "Don't extinguish the fire. You have %d habits left today.",
        "3 hours left! ⏳ Finish your %d habits to save your streaks.",
        "It only takes one spark. ✨ %d habits are waiting for you.",
        "You're on fire! 🔥 Don't let %d habits break your chain.",
        "Protect the flame. 🛡️ %d habits need your attention now!",
        "Keep the fire burning. 🔥 %d habits remaining for today.",
        "Warning: Streaks at risk. 🧯 Complete %d habits to save them!",
        "The chain is strong. 💪 Don't let %d habits break it tonight."
    ]

    func scheduleConsolidatedEmergencyReminder(activeHabits: [Habit]) {
        let center = UNUserNotificationCenter.current()
        let emergencyId = "emergency-daily-summary"
        
        // 1. Filter for habits that are ACTIVE and NOT completed today
        let incompleteHabits = activeHabits.filter { habit in
            habit.habitStatus == .active && !habit.isCompletedToday
        }
        
        // 2. If no incomplete habits, cancel the emergency reminder and return
        if incompleteHabits.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: [emergencyId])
            return
        }
        
        // 3. Prepare the notification logic
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Streak Risk"
        content.sound = .default
        
        let count = incompleteHabits.count
        
        // Dynamic body based on count
        if count == 1 {
            // Personalize for single habit
            let habit = incompleteHabits.first!
            let template = "🔥 Don't let %@ go cold! Check in now to save your %d-day streak."
            content.body = String(format: template, habit.title, habit.currentStreak + 1)
        } else {
            // Generalize for multiple
            let template = consolidatedEmergencyMessages.randomElement() ?? "🔥 %d habits left! Keep your streaks burning."
            content.body = String(format: template, count)
        }
        
        // Trigger: 9:00 PM
        var components = DateComponents()
        components.hour = 21 // 9 PM
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: emergencyId, content: content, trigger: trigger)
        
        center.add(request)
    }

    func cancelNotifications(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        
        var ids = [
            "reminder-\(habit.id.uuidString)", // Legacy single ID
            "motivation-\(habit.id.uuidString)",
            "emergency-\(habit.id.uuidString)" // Cleanup old per-habit emergency IDs
        ]
        
        // Add all current reminder sub-IDs
        for fragment in habit.reminders {
            ids.append("reminder-\(habit.id.uuidString)-\(fragment.id.uuidString)")
        }
        
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func rescheduleAll(habits: [Habit]) {
        let activeHabits = habits.filter { $0.habitStatus == .active }
        
        for habit in activeHabits {
            scheduleReminder(for: habit)
            scheduleMorningMotivation(for: habit)
        }
        
        // Schedule the single consolidated emergency reminder
        scheduleConsolidatedEmergencyReminder(activeHabits: activeHabits)
    }
}
