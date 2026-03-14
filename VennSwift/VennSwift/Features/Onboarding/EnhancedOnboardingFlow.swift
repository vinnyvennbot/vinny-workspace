import SwiftUI

/// Enhanced Onboarding Flow - Premium welcome experience
/// Features: Animated slides, personality quiz, preferences setup
struct EnhancedOnboardingFlow: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @GestureState private var gestureOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    VennColors.darkBg,
                    Color(red: 20/255, green: 15/255, blue: 10/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background particles
            backgroundParticles
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < viewModel.pages.count - 1 {
                        Button {
                            HapticManager.shared.impact(.light)
                            skipToEnd()
                        } label: {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(VennColors.textSecondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                    }
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.top, 54)
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPage(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                .onChange(of: currentPage) { _ in
                    HapticManager.shared.impact(.light)
                }
                
                // Page indicators
                pageIndicators
                    .padding(.top, 20)
                
                // Action button
                actionButton
                    .padding(.horizontal, VennSpacing.xl)
                    .padding(.top, 32)
                    .padding(.bottom, 50)
            }
        }
    }
    
    // MARK: - Background Particles
    
    private var backgroundParticles: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                VennColors.coral.opacity(Double.random(in: 0.05...0.15)),
                                VennColors.gold.opacity(Double.random(in: 0.03...0.1))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 60...180))
                    .blur(radius: CGFloat.random(in: 20...40))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -300...300)
                    )
                    .floating(
                        range: CGFloat.random(in: 15...40),
                        duration: Double.random(in: 4...8)
                    )
            }
        }
    }
    
    // MARK: - Page Indicators
    
    private var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.pages.count, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? VennColors.coral : Color.white.opacity(0.3))
                    .frame(width: currentPage == index ? 32 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button {
            handleActionButton()
        } label: {
            HStack(spacing: 12) {
                Text(currentPage == viewModel.pages.count - 1 ? "Get Started" : "Next")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                if currentPage == viewModel.pages.count - 1 {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [VennColors.coral, VennColors.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: VennColors.coral.opacity(0.5), radius: 20, y: 10)
            )
        }
    }
    
    // MARK: - Actions
    
    private func handleActionButton() {
        HapticManager.shared.impact(.medium)
        
        if currentPage < viewModel.pages.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else {
            // Complete onboarding
            viewModel.completeOnboarding()
            ToastManager.shared.showSuccess("Welcome to Venn! 🎉")
        }
    }
    
    private func skipToEnd() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentPage = viewModel.pages.count - 1
        }
    }
}

// MARK: - Onboarding Page

struct OnboardingPage: View {
    let page: OnboardingPageData
    let index: Int
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                // Glow
                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                    .scaleEffect(appeared ? 1.2 : 0.8)
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.color, page.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: page.color.opacity(0.4), radius: 20, y: 10)
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .offset(y: appeared ? 0 : 30)
                    .opacity(appeared ? 1 : 0)
                
                Text(page.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .offset(y: appeared ? 0 : 30)
                    .opacity(appeared ? 1 : 0)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Page Data

struct OnboardingPageData: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - View Model
//
// OnboardingViewModel is defined in OnboardingViewModel.swift.
// The stub that previously lived here has been removed to avoid a
// "redeclaration of type" compile error — use the authoritative version
// in OnboardingViewModel.swift which includes all preference fields,
// step validation, network save, and offline fallback logic.

// MARK: - Preview

#Preview {
    EnhancedOnboardingFlow()
        .withToasts()
}
