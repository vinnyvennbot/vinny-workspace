import SwiftUI

@main
struct VennApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(appState)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Configure analytics
        AnalyticsService.shared.configure()
        
        // Check authentication status
        Task {
            await authManager.checkAuthStatus()
        }
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .events
    @Published var isShowingOnboarding = false
    @Published var networkStatus: NetworkStatus = .connected
    
    enum Tab {
        case events
        case friends
        case plans
        case profile
    }
    
    enum NetworkStatus {
        case connected
        case disconnected
        case slow
    }
}
