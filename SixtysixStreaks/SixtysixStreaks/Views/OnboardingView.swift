import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var showCreateHabit = false

    var body: some View {
        ZStack {
            Color(hex: "111111").ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    screenOne.tag(0)
                    screenTwo.tag(1)
                    screenThree.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white.opacity(0.9) : Color.white.opacity(0.15))
                            .frame(width: 5, height: 5)
                    }
                }
                .padding(.bottom, 32)

                // CTA
                Button {
                    handleCTA()
                } label: {
                    Text(ctaText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(hex: "3B82F6"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showCreateHabit) {
            CreateHabitView(isOnboarding: true) {
                hasCompletedOnboarding = true
            }
        }
    }

    // MARK: - CTA

    private var ctaText: String {
        switch currentPage {
        case 0: return "Get Started"
        case 1: return "Continue"
        case 2: return "Start My Habit"
        default: return "Continue"
        }
    }

    private func handleCTA() {
        if currentPage < 2 {
            withAnimation {
                currentPage += 1
            }
        } else {
            showCreateHabit = true
        }
    }

    // MARK: - Screen 1: Hook

    private var screenOne: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)

            Spacer()
                .frame(height: 40)

            Text("Build one habit\nin 66 days.")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
                .frame(height: 16)

            Text("Show up daily.\nThat's it.")
                .font(.system(size: 18))
                .foregroundColor(Color.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Screen 2: Why 66

    private var screenTwo: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("66 days")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Spacer()
                .frame(height: 16)

            Text("That’s how long habits take to stick.")
                .font(.system(size: 18))
                .foregroundColor(Color.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Screen 3: Commitment

    private var screenThree: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Miss a day. Reset.")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Spacer()
                .frame(height: 16)

            Text("Consistency builds identity.")
                .font(.system(size: 18))
                .foregroundColor(Color.white.opacity(0.85))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .modelContainer(for: Habit.self, inMemory: true)
}
