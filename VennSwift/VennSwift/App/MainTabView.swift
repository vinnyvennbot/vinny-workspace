import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            EventsView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
                .tag(AppState.Tab.events)
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                .tag(AppState.Tab.friends)
            
            // Vivi - Center tab (AI companion)
            ViviChatView()
                .tabItem {
                    Label("Vivi", systemImage: "sparkle.magnifyingglass")
                }
                .tag(AppState.Tab.vivi)
            
            PlansView()
                .tabItem {
                    Label("Plans", systemImage: "calendar.badge.clock")
                }
                .tag(AppState.Tab.plans)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(AppState.Tab.profile)
        }
        .tint(Color(red: 255/255, green: 127/255, blue: 110/255)) // Venn coral
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager.shared)
}
