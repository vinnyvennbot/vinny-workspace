import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.orange)
                        }
                    
                    // User Info
                    if let user = authManager.currentUser {
                        VStack(spacing: 8) {
                            Text(user.displayName)
                                .font(.title2.bold())
                            
                            if let city = user.city {
                                Text(city)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Profile Actions
                    VStack(spacing: 16) {
                        ProfileActionRow(icon: "pencil", title: "Edit Profile") {
                            // TODO: Edit profile
                        }
                        
                        ProfileActionRow(icon: "gear", title: "Settings") {
                            // TODO: Settings
                        }
                        
                        ProfileActionRow(icon: "bell", title: "Notifications") {
                            // TODO: Notifications
                        }
                        
                        ProfileActionRow(icon: "questionmark.circle", title: "Help & Support") {
                            // TODO: Help
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Button {
                            showingLogoutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    Task {
                        await authManager.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

// MARK: - Profile Action Row

struct ProfileActionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager.shared)
}
