import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            switch authManager.state {
            case .loading:
                LoadingView()
            case .unauthenticated:
                AuthFlowView()
            case .authenticated(needsOnboarding: true):
                OnboardingFlowView()
            case .authenticated(needsOnboarding: false):
                MainTabView()
            }
        }
        .animation(.easeInOut, value: authManager.state)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)
                
                Text("Venn")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.orange)
                
                ProgressView()
                    .tint(.orange)
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(AppState())
}
