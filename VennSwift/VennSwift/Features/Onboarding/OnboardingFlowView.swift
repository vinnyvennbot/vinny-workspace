import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 32) {
            // Progress
            ProgressView(value: Double(currentStep), total: 5)
                .tint(.orange)
                .padding(.horizontal)
            
            Spacer()
            
            // Step Content
            Group {
                switch currentStep {
                case 0:
                    onboardingStep(
                        icon: "person.text.rectangle",
                        title: "Tell us about yourself",
                        description: "We'll use this to personalize your experience"
                    )
                case 1:
                    onboardingStep(
                        icon: "location.fill",
                        title: "Where are you?",
                        description: "Find events and friends in your city"
                    )
                case 2:
                    onboardingStep(
                        icon: "calendar",
                        title: "When are you free?",
                        description: "Help us suggest events at the right time"
                    )
                case 3:
                    onboardingStep(
                        icon: "heart.fill",
                        title: "What do you like?",
                        description: "Tell us your interests and hobbies"
                    )
                case 4:
                    onboardingStep(
                        icon: "checkmark.circle.fill",
                        title: "All set!",
                        description: "You're ready to connect"
                    )
                default:
                    EmptyView()
                }
            }
            
            Spacer()
            
            // Actions
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        currentStep -= 1
                    }
                    .foregroundStyle(.orange)
                }
                
                Spacer()
                
                Button(currentStep == 4 ? "Get Started" : "Continue") {
                    if currentStep == 4 {
                        authManager.completeOnboarding()
                    } else {
                        currentStep += 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding()
        }
        .padding()
    }
    
    private func onboardingStep(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(AuthenticationManager.shared)
}
