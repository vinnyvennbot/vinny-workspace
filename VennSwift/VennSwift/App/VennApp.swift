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
        Task {
            await AnalyticsService.shared.configure()
        }

        // TEMP: Skipped to preview onboarding — uncomment when done
        // Task {
        //     await authManager.checkAuthStatus()
        // }
    }
}
