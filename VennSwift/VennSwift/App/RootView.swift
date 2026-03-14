import SwiftUI

// MARK: - RootView
// Routes between auth states. Premium transitions throughout.

struct RootView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch authManager.state {
            case .loading:
                LoadingView()
                    .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .opacity.combined(with: .scale(scale: 0.96))
                        )
                    )
            case .unauthenticated:
                AuthFlowView()
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.03)),
                            removal: .opacity.combined(with: .scale(scale: 0.97))
                        )
                    )
            case .authenticated(needsOnboarding: true):
                OnboardingFlowView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            case .authenticated(needsOnboarding: false):
                MainTabView()
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.02)),
                            removal: .opacity
                        )
                    )
            }
        }
        .animation(VennAnimation.gentle, value: authManager.state)
    }
}

// MARK: - Loading View
// Full-screen premium splash shown while auth status is being checked.

struct LoadingView: View {
    @State private var logoAppeared  = false
    @State private var glowScale: CGFloat = 0.6
    @State private var glowOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Background
            VennColors.darkBg.ignoresSafeArea()

            // Ambient coral glow behind logo
            Circle()
                .fill(VennColors.coral.opacity(0.12))
                .frame(width: 300, height: 300)
                .scaleEffect(glowScale)
                .opacity(glowOpacity)
                .blur(radius: 60)

            VStack(spacing: VennSpacing.xl) {
                Spacer()

                // Logo mark
                logoMark

                // Wordmark
                Text("Venn")
                    .font(VennTypography.displayLarge)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [VennColors.coral, VennColors.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(logoAppeared ? 1 : 0)
                    .offset(y: logoAppeared ? 0 : 10)

                Text("connect through experiences")
                    .font(VennTypography.body)
                    .foregroundColor(VennColors.textTertiary)
                    .opacity(logoAppeared ? 1 : 0)
                    .offset(y: logoAppeared ? 0 : 6)

                Spacer()

                // Subtle spinner at bottom
                VennSpinner()
                    .opacity(logoAppeared ? 0.7 : 0)
                    .padding(.bottom, VennSpacing.massive)
            }
        }
        .onAppear {
            withAnimation(VennAnimation.gentle.delay(0.15)) {
                logoAppeared = true
            }
            withAnimation(
                Animation.easeInOut(duration: 2.4)
                    .repeatForever(autoreverses: true)
                    .delay(0.3)
            ) {
                glowScale   = 1.1
                glowOpacity = 1.0
            }
        }
    }

    // MARK: Logo mark — overlapping circles motif

    private var logoMark: some View {
        ZStack {
            // Left circle
            Circle()
                .fill(VennColors.coral.opacity(0.20))
                .frame(width: 56, height: 56)
                .offset(x: -16)

            // Right circle
            Circle()
                .fill(VennColors.gold.opacity(0.20))
                .frame(width: 56, height: 56)
                .offset(x: 16)

            // Center intersection highlight
            Circle()
                .fill(
                    LinearGradient(
                        colors: [VennColors.coral, VennColors.gold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 28)
                .blur(radius: 0)
        }
        .opacity(logoAppeared ? 1 : 0)
        .scaleEffect(logoAppeared ? 1.0 : 0.7)
        .vennPulse(duration: 2.2)
    }
}

// MARK: - Venn Spinner
// Subtle arc spinner using the brand gradient.

struct VennSpinner: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(VennColors.borderSubtle, lineWidth: 2)
                .frame(width: 28, height: 28)

            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    AngularGradient(
                        colors: [VennColors.coral, VennColors.gold, VennColors.coral.opacity(0)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 28, height: 28)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1.1)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RootView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(AppState())
}

#Preview("Loading") {
    LoadingView()
}
