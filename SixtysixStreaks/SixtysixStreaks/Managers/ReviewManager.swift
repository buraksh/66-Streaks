import StoreKit
import SwiftUI

/// Manages in-app review prompts using SKStoreReviewController.
///
/// Strategic triggers (from ASO strategy §8):
/// - After completing Day 7 (first milestone)
/// - After completing Day 21 ("21-day myth" milestone)
/// - After completing Day 66 (maximum satisfaction)
///
/// Rules:
/// - Max 3 prompts per 365-day period
/// - Only one prompt per app session (prevents stacking)
/// - Never prompt after a missed day (only on successful check-in)
/// - Never prompt on first launch
/// - 2-second delay before showing for better UX
final class ReviewManager {
    static let shared = ReviewManager()

    private let maxPromptsPerYear = 3
    private let promptDelaySeconds: Double = 2.0

    // Milestone days that trigger a review prompt
    private let milestoneDays: Set<Int> = [7, 21, 66]

    // Prevents multiple prompts in the same app session
    private var hasPromptedThisSession = false

    private var promptCount: Int {
        get { UserDefaults.standard.integer(forKey: "reviewPromptCount") }
        set { UserDefaults.standard.set(newValue, forKey: "reviewPromptCount") }
    }

    private var lastPromptDate: Date? {
        get { UserDefaults.standard.object(forKey: "lastReviewPromptDate") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastReviewPromptDate") }
    }

    private var firstPromptEpoch: Date? {
        get { UserDefaults.standard.object(forKey: "reviewPromptEpochStart") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "reviewPromptEpochStart") }
    }

    private init() {}

    // MARK: - Public API

    /// Call after a successful check-in. Checks if the habit's current streak
    /// hits a milestone and whether we're allowed to prompt.
    func requestReviewIfAppropriate(for habit: Habit) {
        guard milestoneDays.contains(habit.currentStreak) else { return }
        guard canPrompt() else { return }

        // Mark immediately to prevent a second prompt before the delay fires
        hasPromptedThisSession = true

        // Delay the prompt slightly for better UX (let the check-in animation finish)
        DispatchQueue.main.asyncAfter(deadline: .now() + promptDelaySeconds) {
            self.presentReview()
        }
    }

    /// Resets all review tracking state. DEBUG only — used for testing.
    func resetState() {
        promptCount = 0
        lastPromptDate = nil
        firstPromptEpoch = nil
        hasPromptedThisSession = false
    }

    // MARK: - Private

    private func canPrompt() -> Bool {
        // Only one prompt per app session
        if hasPromptedThisSession { return false }

        // Reset counter if 365 days have passed since the first prompt in this epoch
        if let epoch = firstPromptEpoch {
            let daysSinceEpoch = Calendar.current.dateComponents([.day], from: epoch, to: Date()).day ?? 0
            if daysSinceEpoch >= 365 {
                promptCount = 0
                firstPromptEpoch = nil
            }
        }

        // Check max prompts per year
        if promptCount >= maxPromptsPerYear {
            return false
        }

        // Avoid prompting too frequently — at least 30 days between prompts
        if let last = lastPromptDate {
            let daysSinceLast = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            if daysSinceLast < 30 {
                return false
            }
        }

        return true
    }

    private func presentReview() {
        // Start a new epoch if this is the first prompt
        if firstPromptEpoch == nil {
            firstPromptEpoch = Date()
        }

        promptCount += 1
        lastPromptDate = Date()

        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
