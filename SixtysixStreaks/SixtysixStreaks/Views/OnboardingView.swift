import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Environment(LanguageManager.self) private var lang
    @State private var currentPage = 0
    @State private var showCreateHabit = false

    // Animation states
    @State private var textVisible = false
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var gradientPhase: CGFloat = 0

    private let totalPages = 2

    var body: some View {
        ZStack {
            // MARK: - Animated Gradient Background
            animatedBackground

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        triggerHaptic()
                        showCreateHabit = true
                    } label: {
                        Text(lang.localized("onboarding.skip"))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                    .padding(.trailing, 28)
                    .padding(.top, 8)
                }

                TabView(selection: $currentPage) {
                    screenOne.tag(0)
                    screenTwo.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)
                .onChange(of: currentPage) { _, _ in
                    // Re-trigger text entrance on page change
                    textVisible = false
                    withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                        textVisible = true
                    }
                }

                // MARK: - Pill Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage
                                  ? Color.white.opacity(0.9)
                                  : Color.white.opacity(0.15))
                            .frame(
                                width: index == currentPage ? 24 : 8,
                                height: 8
                            )
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 28)

                // MARK: - CTA Button with Glow
                Button {
                    triggerHaptic()
                    handleCTA()
                } label: {
                    Text(ctaText)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.ctaGradient)
                        .clipShape(.rect(cornerRadius: 16))
                        .shadow(color: AppTheme.accentBlue.opacity(0.45), radius: 20, x: 0, y: 8)
                        .shadow(color: AppTheme.accentBlue.opacity(0.2), radius: 40, x: 0, y: 4)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Logo entrance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            // Text entrance
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                textVisible = true
            }
            // Gradient animation loop
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                gradientPhase = 1.0
            }
        }
        .sheet(isPresented: $showCreateHabit) {
            CreateHabitView(isOnboarding: true) {
                hasCompletedOnboarding = true
            }
        }
    }

    // MARK: - Animated Background

    private var animatedBackground: some View {
        ZStack {
            Color(hex: "111111").ignoresSafeArea()

            // Ambient glow — top-left (neutral warm gray)
            RadialGradient(
                colors: [
                    Color(hex: "1C1C1E").opacity(0.8 * (1.0 - Double(gradientPhase) * 0.2)),
                    Color.clear
                ],
                center: .init(
                    x: 0.25 + Double(gradientPhase) * 0.15,
                    y: 0.15 + Double(gradientPhase) * 0.08
                ),
                startRadius: 60,
                endRadius: 320
            )
            .ignoresSafeArea()

            // Ambient glow — bottom-right (neutral cool gray)
            RadialGradient(
                colors: [
                    Color(hex: "2C2C2E").opacity(0.4 * (0.7 + Double(gradientPhase) * 0.3)),
                    Color.clear
                ],
                center: .init(
                    x: 0.72 - Double(gradientPhase) * 0.12,
                    y: 0.7 - Double(gradientPhase) * 0.08
                ),
                startRadius: 40,
                endRadius: 280
            )
            .ignoresSafeArea()

            // Accent blue glow — center (brand warmth)
            RadialGradient(
                colors: [
                    AppTheme.accentBlue.opacity(0.06 + Double(gradientPhase) * 0.03),
                    Color.clear
                ],
                center: .init(
                    x: 0.5,
                    y: 0.4 + Double(gradientPhase) * 0.06
                ),
                startRadius: 10,
                endRadius: 280
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - CTA Logic

    private var ctaText: String {
        switch currentPage {
        case 0: return lang.localized("onboarding.continue")
        case 1: return lang.localized("onboarding.start_my_habit")
        default: return lang.localized("onboarding.continue")
        }
    }

    private func handleCTA() {
        if currentPage < totalPages - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            showCreateHabit = true
        }
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // MARK: - Screen 1: Hook + Science

    private var screenOne: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Logo with entrance animation
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

            Spacer()
                .frame(height: 48)

            // Headline
            Text(lang.localized("onboarding.screen1.headline"))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(textVisible ? 1 : 0)
                .offset(y: textVisible ? 0 : 20)

            Spacer()
                .frame(height: 16)

            // Subtitle
            Text(lang.localized("onboarding.screen1.subtitle"))
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .opacity(textVisible ? 1 : 0)
                .offset(y: textVisible ? 0 : 16)

            Spacer()
                .frame(height: 32)

            // Science badge
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "A78BFA"))
                Text(lang.localized("onboarding.screen1.badge"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.06))
            .clipShape(Capsule())
            .opacity(textVisible ? 1 : 0)
            .offset(y: textVisible ? 0 : 12)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Screen 2: Promise + CTA

    private var screenTwo: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Visual anchor
            ZStack {
                // Glow behind icon
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.accentBlue.opacity(0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "sparkles")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "A78BFA"),
                                Color(hex: "60A5FA"),
                                Color(hex: "34D399")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse.byLayer, options: .repeating)
            }

            Spacer()
                .frame(height: 48)

            // Headline
            Text(lang.localized("onboarding.screen2.headline"))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .opacity(textVisible ? 1 : 0)
                .offset(y: textVisible ? 0 : 20)

            Spacer()
                .frame(height: 16)

            // Subtitle
            Text(lang.localized("onboarding.screen2.subtitle"))
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .opacity(textVisible ? 1 : 0)
                .offset(y: textVisible ? 0 : 16)

            Spacer()
                .frame(height: 32)

            // Social proof
            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "34D399"))
                Text(lang.localized("onboarding.screen2.badge"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.06))
            .clipShape(Capsule())
            .opacity(textVisible ? 1 : 0)
            .offset(y: textVisible ? 0 : 12)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .modelContainer(for: Habit.self, inMemory: true)
        .environment(LanguageManager.shared)
}
