import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingLogoutAlert = false
    @State private var logoutShake = false

    // Sheet presentation state
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingNotifications = false
    @State private var showingHelpSupport = false

    // Entrance animation states
    @State private var avatarVisible = false
    @State private var nameVisible = false
    @State private var statsVisible = false
    @State private var shareVisible = false

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: VennSpacing.xxl) {
                    // Avatar + identity
                    avatarSection

                    // Stats row
                    // NOTE: Stats values (12 events, 47 friends, 5 plans) are currently
                    // mock data — these should be populated from the user profile API endpoint.
                    statsSection

                    // Share Profile button
                    shareProfileButton

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
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheet(user: authManager.currentUser)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheet()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsSheet()
        }
        .sheet(isPresented: $showingHelpSupport) {
            HelpSupportSheet()
        }
        .onAppear {
            withAnimation(VennAnimation.gentle) {
                avatarVisible = true
            }
            withAnimation(VennAnimation.gentle.delay(0.15)) {
                nameVisible = true
            }
            withAnimation(VennAnimation.gentle.delay(0.28)) {
                statsVisible = true
            }
            withAnimation(VennAnimation.gentle.delay(0.38)) {
                shareVisible = true
            }
        }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: VennSpacing.lg) {
            if let user = authManager.currentUser {
                // Avatar with glow and edit overlay
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(VennGradients.primary)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text(String(user.displayName.prefix(1)))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .glow(color: VennColors.coral, radius: 20, intensity: 0.4)

                    // Edit button overlay
                    Circle()
                        .fill(VennColors.surfaceTertiary)
                        .overlay(
                            Circle()
                                .stroke(VennColors.borderMedium, lineWidth: 1)
                        )
                        .frame(width: 26, height: 26)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(VennColors.textSecondary)
                        )
                        .offset(x: 2, y: 2)
                }
                .scaleEffect(avatarVisible ? 1.0 : 0.7)
                .opacity(avatarVisible ? 1.0 : 0.0)

                // Name + city + Member badge
                VStack(spacing: VennSpacing.sm) {
                    Text(user.displayName)
                        .font(VennTypography.subheading)
                        .foregroundColor(VennColors.textPrimary)

                    // Venn Member badge
                    Text("Member")
                        .font(VennTypography.captionBold)
                        .foregroundColor(.white)
                        .padding(.horizontal, VennSpacing.md)
                        .padding(.vertical, VennSpacing.xs)
                        .background(
                            Capsule(style: .continuous)
                                .fill(VennGradients.primary)
                        )

                    if let city = user.profile.City {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(VennColors.textSecondary)
                            Text(city)
                                .font(VennTypography.caption)
                                .foregroundColor(VennColors.textSecondary)
                        }
                    }
                }
                .opacity(nameVisible ? 1.0 : 0.0)
                .offset(y: nameVisible ? 0 : 8)
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: 0) {
            ProfileStatColumn(value: "12", label: "Events\nAttended")
            Divider()
                .frame(width: 1, height: 36)
                .background(VennColors.borderSubtle)
            ProfileStatColumn(value: "47", label: "Friends")
            Divider()
                .frame(width: 1, height: 36)
                .background(VennColors.borderSubtle)
            ProfileStatColumn(value: "5", label: "Plans")
        }
        .padding(.vertical, VennSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                .fill(VennColors.surfacePrimary)
        )
        .opacity(statsVisible ? 1.0 : 0.0)
        .offset(y: statsVisible ? 0 : 12)
    }

    // MARK: - Share Profile Button

    private var shareProfileButton: some View {
        let username = authManager.currentUser?.displayName
            .lowercased()
            .replacingOccurrences(of: " ", with: "") ?? "user"
        let shareText = "Check out my profile on Venn! venn.app/@\(username)"

        return ShareLink(item: shareText) {
            HStack(spacing: VennSpacing.sm) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                Text("Share Profile")
                    .font(VennTypography.buttonLabel)
            }
            .foregroundColor(VennColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                    .fill(VennColors.glassLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                            .stroke(VennColors.borderMedium, lineWidth: 1)
                    )
            )
        }
        .simultaneousGesture(TapGesture().onEnded {
            HapticManager.shared.selectionFeedback()
        })
        .opacity(shareVisible ? 1.0 : 0.0)
        .offset(y: shareVisible ? 0 : 8)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            ProfileRow(
                icon: "pencil.circle.fill",
                iconColor: VennColors.coral,
                title: "Edit Profile",
                isLast: false
            ) {
                showingEditProfile = true
            }

            ProfileRow(
                icon: "gear.circle.fill",
                iconColor: Color(red: 120/255, green: 170/255, blue: 255/255),
                title: "Settings",
                isLast: false
            ) {
                showingSettings = true
            }

            ProfileRow(
                icon: "bell.circle.fill",
                iconColor: VennColors.gold,
                title: "Notifications",
                isLast: false
            ) {
                showingNotifications = true
            }

            ProfileRow(
                icon: "questionmark.circle.fill",
                iconColor: Color(red: 140/255, green: 200/255, blue: 120/255),
                title: "Help & Support",
                isLast: true
            ) {
                showingHelpSupport = true
            }
        }
        .background(
            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                .fill(VennColors.surfacePrimary)
        )
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button {
            logoutShake.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                showingLogoutAlert = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(VennTypography.buttonLabel)
                Text("Log Out")
                    .font(VennTypography.buttonLabel)
            }
            .foregroundColor(VennColors.error)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                    .fill(VennColors.error.opacity(0.08))
            )
        }
        .shake(trigger: logoutShake)
    }
}

// MARK: - Edit Profile Sheet

private struct EditProfileSheet: View {
    let user: User?
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var saveShake = false

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(VennColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(VennColors.surfaceTertiary))
                    }

                    Spacer()

                    Text("Edit Profile")
                        .font(VennTypography.subheading)
                        .foregroundColor(VennColors.textPrimary)

                    Spacer()

                    // Balance spacer
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.top, VennSpacing.xl)
                .padding(.bottom, VennSpacing.lg)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: VennSpacing.lg) {
                        // Avatar preview
                        Circle()
                            .fill(VennGradients.primary)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Text(String((displayName.isEmpty ? user?.displayName ?? "?" : displayName).prefix(1)))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                            .padding(.bottom, VennSpacing.sm)

                        // Name field
                        VStack(alignment: .leading, spacing: VennSpacing.sm) {
                            Text("Display Name")
                                .font(VennTypography.captionBold)
                                .foregroundColor(VennColors.textSecondary)

                            TextField("", text: $displayName, prompt:
                                Text("Your name").foregroundColor(VennColors.textTertiary)
                            )
                            .font(VennTypography.bodyLarge)
                            .foregroundColor(VennColors.textPrimary)
                            .padding(.horizontal, VennSpacing.lg)
                            .padding(.vertical, VennSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                    .fill(VennColors.surfacePrimary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                            .stroke(VennColors.borderMedium, lineWidth: 1)
                                    )
                            )
                        }

                        // Bio field
                        VStack(alignment: .leading, spacing: VennSpacing.sm) {
                            Text("Bio")
                                .font(VennTypography.captionBold)
                                .foregroundColor(VennColors.textSecondary)

                            TextField("", text: $bio, prompt:
                                Text("Tell people about yourself...").foregroundColor(VennColors.textTertiary),
                                axis: .vertical
                            )
                            .font(VennTypography.bodyLarge)
                            .foregroundColor(VennColors.textPrimary)
                            .lineLimit(4, reservesSpace: true)
                            .padding(.horizontal, VennSpacing.lg)
                            .padding(.vertical, VennSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                    .fill(VennColors.surfacePrimary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                            .stroke(VennColors.borderMedium, lineWidth: 1)
                                    )
                            )
                        }

                        // Save button
                        Button {
                            HapticManager.shared.impact(.medium)
                            dismiss()
                        } label: {
                            Text("Save Changes")
                                .font(VennTypography.buttonLabel)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    Capsule()
                                        .fill(VennGradients.primary)
                                )
                        }
                        .padding(.top, VennSpacing.md)
                    }
                    .padding(.horizontal, VennSpacing.xl)
                    .padding(.bottom, VennSpacing.huge)
                }
            }
        }
        .onAppear {
            displayName = user?.displayName ?? ""
        }
    }
}

// MARK: - Settings Sheet

private struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(VennColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(VennColors.surfaceTertiary))
                    }

                    Spacer()

                    Text("Settings")
                        .font(VennTypography.subheading)
                        .foregroundColor(VennColors.textPrimary)

                    Spacer()

                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.top, VennSpacing.xl)
                .padding(.bottom, VennSpacing.lg)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: VennSpacing.lg) {
                        // Preferences section
                        VStack(spacing: 0) {
                            settingsToggleRow(
                                icon: "bell.fill",
                                iconColor: VennColors.gold,
                                title: "Push Notifications",
                                isOn: $notificationsEnabled,
                                isLast: false
                            )
                            settingsToggleRow(
                                icon: "location.fill",
                                iconColor: VennColors.coral,
                                title: "Location Access",
                                isOn: $locationEnabled,
                                isLast: false
                            )
                            // Dark mode is locked on — display-only
                            HStack(spacing: 14) {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(VennColors.indigo)
                                    .frame(width: 32)

                                Text("Dark Mode")
                                    .font(VennTypography.bodyMedium)
                                    .foregroundColor(VennColors.textPrimary)

                                Spacer()

                                Text("Always On")
                                    .font(VennTypography.caption)
                                    .foregroundColor(VennColors.textTertiary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 15)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                                .fill(VennColors.surfacePrimary)
                        )

                        // About section
                        VStack(spacing: 0) {
                            HStack(spacing: 14) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(VennColors.textSecondary)
                                    .frame(width: 32)

                                Text("Version")
                                    .font(VennTypography.bodyMedium)
                                    .foregroundColor(VennColors.textPrimary)

                                Spacer()

                                Text("\(appVersion) (\(buildNumber))")
                                    .font(VennTypography.caption)
                                    .foregroundColor(VennColors.textTertiary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 15)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                                .fill(VennColors.surfacePrimary)
                        )
                    }
                    .padding(.horizontal, VennSpacing.xl)
                    .padding(.bottom, VennSpacing.huge)
                }
            }
        }
    }

    private func settingsToggleRow(
        icon: String,
        iconColor: Color,
        title: String,
        isOn: Binding<Bool>,
        isLast: Bool
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 32)

            Text(title)
                .font(VennTypography.bodyMedium)
                .foregroundColor(VennColors.textPrimary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(VennColors.coral)
                .onChange(of: isOn.wrappedValue) { _ in
                    HapticManager.shared.selectionFeedback()
                }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
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

// MARK: - Notifications Sheet

private struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var eventReminders = true
    @State private var friendRequests = true
    @State private var newEventsNearby = false
    @State private var planUpdates = true

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(VennColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(VennColors.surfaceTertiary))
                    }

                    Spacer()

                    Text("Notifications")
                        .font(VennTypography.subheading)
                        .foregroundColor(VennColors.textPrimary)

                    Spacer()

                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.top, VennSpacing.xl)
                .padding(.bottom, VennSpacing.lg)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: VennSpacing.lg) {
                        Text("Choose what you want to be notified about")
                            .font(VennTypography.body)
                            .foregroundColor(VennColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, VennSpacing.xl)

                        VStack(spacing: 0) {
                            notifToggleRow(
                                icon: "calendar.badge.clock",
                                iconColor: VennColors.coral,
                                title: "Event Reminders",
                                subtitle: "Get reminded before events you're attending",
                                isOn: $eventReminders,
                                isLast: false
                            )
                            notifToggleRow(
                                icon: "person.badge.plus",
                                iconColor: VennColors.indigo,
                                title: "Friend Requests",
                                subtitle: "When someone wants to connect",
                                isOn: $friendRequests,
                                isLast: false
                            )
                            notifToggleRow(
                                icon: "location.circle.fill",
                                iconColor: VennColors.gold,
                                title: "New Events Nearby",
                                subtitle: "Discover events happening around you",
                                isOn: $newEventsNearby,
                                isLast: false
                            )
                            notifToggleRow(
                                icon: "bell.badge.fill",
                                iconColor: Color(red: 140/255, green: 200/255, blue: 120/255),
                                title: "Plan Updates",
                                subtitle: "Changes to events you've RSVP'd to",
                                isOn: $planUpdates,
                                isLast: true
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                                .fill(VennColors.surfacePrimary)
                        )
                        .padding(.horizontal, VennSpacing.xl)
                    }
                    .padding(.bottom, VennSpacing.huge)
                }
            }
        }
    }

    private func notifToggleRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        isLast: Bool
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(VennTypography.bodyMedium)
                    .foregroundColor(VennColors.textPrimary)
                Text(subtitle)
                    .font(VennTypography.caption)
                    .foregroundColor(VennColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(VennColors.coral)
                .onChange(of: isOn.wrappedValue) { _ in
                    HapticManager.shared.selectionFeedback()
                }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
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

// MARK: - Help & Support Sheet

private struct HelpSupportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var emailCopied = false

    private let supportEmail = "support@vennapp.co"

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(VennColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(VennColors.surfaceTertiary))
                    }

                    Spacer()

                    Text("Help & Support")
                        .font(VennTypography.subheading)
                        .foregroundColor(VennColors.textPrimary)

                    Spacer()

                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.top, VennSpacing.xl)
                .padding(.bottom, VennSpacing.lg)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: VennSpacing.xl) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(VennColors.coralSubtle)
                                .frame(width: 80, height: 80)

                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(VennColors.coral)
                        }
                        .padding(.top, VennSpacing.lg)

                        VStack(spacing: VennSpacing.sm) {
                            Text("We're here to help")
                                .font(VennTypography.subheading)
                                .foregroundColor(VennColors.textPrimary)

                            Text("Reach out to our team and we'll get back to you within 24 hours.")
                                .font(VennTypography.body)
                                .foregroundColor(VennColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, VennSpacing.xl)

                        // Email card
                        VStack(spacing: VennSpacing.md) {
                            HStack(spacing: VennSpacing.md) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(VennColors.coral)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Email Support")
                                        .font(VennTypography.bodyMedium)
                                        .foregroundColor(VennColors.textPrimary)
                                    Text(supportEmail)
                                        .font(VennTypography.caption)
                                        .foregroundColor(VennColors.textSecondary)
                                }

                                Spacer()
                            }

                            Button {
                                UIPasteboard.general.string = supportEmail
                                HapticManager.shared.impact(.light)
                                withAnimation(VennAnimation.snappy) { emailCopied = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation(VennAnimation.gentle) { emailCopied = false }
                                }
                            } label: {
                                HStack(spacing: VennSpacing.sm) {
                                    Image(systemName: emailCopied ? "checkmark" : "doc.on.doc")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(emailCopied ? "Copied!" : "Copy Email")
                                        .font(VennTypography.buttonLabel)
                                }
                                .foregroundColor(emailCopied ? VennColors.success : VennColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                        .fill(emailCopied ? VennColors.success.opacity(0.12) : VennColors.surfaceTertiary)
                                )
                            }
                            .animation(VennAnimation.snappy, value: emailCopied)
                        }
                        .padding(VennSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                                .fill(VennColors.surfacePrimary)
                        )
                        .padding(.horizontal, VennSpacing.xl)
                    }
                    .padding(.bottom, VennSpacing.huge)
                }
            }
        }
    }
}

// MARK: - Profile Stat Column

private struct ProfileStatColumn: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: VennSpacing.xs) {
            Text(value)
                .font(VennTypography.subheading)
                .foregroundColor(VennColors.textPrimary)
            Text(label)
                .font(VennTypography.caption)
                .foregroundColor(VennColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Row

struct ProfileRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var isLast: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
                    .frame(width: 32)

                Text(title)
                    .font(VennTypography.bodyMedium)
                    .foregroundColor(VennColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(VennColors.textTertiary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(VennAnimation.micro, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
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
