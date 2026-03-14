import SwiftUI

// MARK: - Local Design Tokens
private let darkBg     = Color(red: 15/255,  green: 13/255,  blue: 11/255)
private let cardBg     = Color(red: 26/255,  green: 23/255,  blue: 20/255)
private let coral      = Color(red: 255/255, green: 127/255, blue: 110/255)
private let warmGold   = Color(red: 255/255, green: 185/255, blue: 106/255)
private let warmWhite  = Color(red: 250/255, green: 247/255, blue: 242/255)
private let mutedText  = Color(red: 160/255, green: 152/255, blue: 140/255)

// MARK: - Step Data

private struct OnboardingStep {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

private let steps: [OnboardingStep] = [
    OnboardingStep(icon: "person.text.rectangle.fill", title: "Tell us about yourself",  description: "We'll use this to personalise your experience and match you with the right people.", accentColor: Color(red: 255/255, green: 127/255, blue: 110/255)),
    OnboardingStep(icon: "location.fill",              title: "Where are you?",           description: "Find curated events and friends right in your city.",                                accentColor: Color(red: 255/255, green: 185/255, blue: 106/255)),
    OnboardingStep(icon: "calendar.badge.clock",       title: "When are you free?",       description: "Help us suggest experiences at exactly the right time for you.",                    accentColor: Color(red: 140/255, green: 200/255, blue: 120/255)),
    OnboardingStep(icon: "heart.fill",                 title: "What do you like?",        description: "Tell us your interests and hobbies so we can curate your perfect night.",           accentColor: Color(red: 200/255, green: 130/255, blue: 255/255)),
    OnboardingStep(icon: "checkmark.seal.fill",        title: "You're all set!",          description: "Welcome to Venn — where extraordinary experiences begin.",                         accentColor: Color(red: 255/255, green: 127/255, blue: 110/255))
]

// MARK: - OnboardingFlowView

struct OnboardingFlowView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentStep = 0

    private let totalSteps = 5

    var body: some View {
        ZStack {
            darkBg.ignoresSafeArea()

            // Ambient glow behind the icon
            Circle()
                .fill(steps[currentStep].accentColor.opacity(0.08))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(y: -80)
                .animation(.easeInOut(duration: 0.6), value: currentStep)

            VStack(spacing: 0) {
                // Step dots
                stepDots
                    .padding(.top, 56)

                Spacer()

                // Step content
                stepContent(for: steps[currentStep])
                    .id(currentStep)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)
                        )
                    )

                Spacer()

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 28)
                    .padding(.bottom, 52)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: currentStep)
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(index == currentStep ? coral : Color.white.opacity(0.15))
                    .frame(width: index == currentStep ? 24 : 8, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentStep)
            }
        }
    }

    // MARK: - Step Content

    private func stepContent(for step: OnboardingStep) -> some View {
        VStack(spacing: 32) {
            // Icon
            ZStack {
                Circle()
                    .fill(step.accentColor.opacity(0.12))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(step.accentColor.opacity(0.06))
                    .frame(width: 160, height: 160)

                Image(systemName: step.icon)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [step.accentColor, step.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Text
            VStack(spacing: 14) {
                Text(step.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(warmWhite)
                    .multilineTextAlignment(.center)

                Text(step.description)
                    .font(.system(size: 17))
                    .foregroundColor(mutedText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if currentStep > 0 {
                Button {
                    withAnimation {
                        currentStep -= 1
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(mutedText)
                    .frame(height: 56)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                }
            }

            // Continue / Get Started button
            Button {
                if currentStep == totalSteps - 1 {
                    authManager.completeOnboarding()
                } else {
                    withAnimation {
                        currentStep += 1
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(currentStep == totalSteps - 1 ? "Get Started" : "Continue")
                        .font(.system(size: 17, weight: .bold))

                    if currentStep < totalSteps - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [coral, warmGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: coral.opacity(0.35), radius: 16, y: 6)
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingFlowView()
        .environmentObject(AuthenticationManager.shared)
}
