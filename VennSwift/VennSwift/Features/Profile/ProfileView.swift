import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingLogoutAlert = false

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: VennSpacing.xxl) {
                    // Avatar + identity
                    avatarSection

                    // Settings rows
                    settingsSection

                    // Logout
                    logoutButton

                    Spacer(minLength: VennSpacing.huge)
                }
                .padding(.top, VennSpacing.xxl)
                .padding(.horizontal, VennSpacing.xl)
                .padding(.bottom, VennSpacing.huge)
            }
        }
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                Task { await authManager.logout() }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: VennSpacing.lg) {
            // Avatar — filled gradient circle with initial
            if let user = authManager.currentUser {
                Circle()
                    .fill(VennGradients.primary)
                    .frame(width: 90, height: 90)
                    .overlay(
                        Text(String(user.displayName.prefix(1)))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )

                // Name + city
                VStack(spacing: 6) {
                    Text(user.displayName)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(VennColors.textPrimary)

                    if let city = user.profile.City {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(VennColors.textSecondary)
                            Text(city)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(VennColors.textSecondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            ProfileRow(
                icon: "pencil.circle.fill",
                iconColor: VennColors.coral,
                title: "Edit Profile",
                isLast: false
            ) {}

            ProfileRow(
                icon: "gear.circle.fill",
                iconColor: Color(red: 120/255, green: 170/255, blue: 255/255),
                title: "Settings",
                isLast: false
            ) {}

            ProfileRow(
                icon: "bell.circle.fill",
                iconColor: VennColors.gold,
                title: "Notifications",
                isLast: false
            ) {}

            ProfileRow(
                icon: "questionmark.circle.fill",
                iconColor: Color(red: 140/255, green: 200/255, blue: 120/255),
                title: "Help & Support",
                isLast: true
            ) {}
        }
        .background(
            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                .fill(VennColors.surfacePrimary)
        )
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button {
            showingLogoutAlert = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Log Out")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(VennColors.error)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(VennColors.error.opacity(0.08))
            )
        }
    }
}

// MARK: - Profile Row

struct ProfileRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var isLast: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
                    .frame(width: 32)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(VennColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(VennColors.textTertiary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
        }
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(VennColors.borderSubtle)
                    .frame(height: 0.5)
                    .padding(.leading, 64)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager.shared)
}
