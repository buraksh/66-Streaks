import SwiftUI
import SwiftData

struct ContentView: View {
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        if hasCompletedOnboarding {
            HomeView()
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}

#Preview {
    ContentView(hasCompletedOnboarding: .constant(true))
        .modelContainer(for: Habit.self, inMemory: true)
}
