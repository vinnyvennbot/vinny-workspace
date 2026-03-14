import SwiftUI

/// Enhanced Profile View - Premium user profile
/// Features: Photo editing, stats, settings, achievements
struct EnhancedProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var showingSettings = false
    @State private var showingEditProfile = false
    
    var body: some View {
        ZStack {
            // Background
            VennColors.darkBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with hero image
                    profileHeader
                    
                    // Stats cards
                    statsSection
                        .padding(.top, -40)
                    
                    // Quick actions
                    quickActions
                        .padding(.top, 24)
                    
                    // Achievements
                    achievementsSection
                        .padding(.top, 32)
                    
                    // Settings list
                    settingsSection
                        .padding(.top, 32)
                    
                    // Logout button
                    logoutButton
                        .padding(.top, 32)
                        .padding(.bottom, 100)
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EnhancedEditProfileSheet()
        }
        .sheet(isPresented: $showingSettings) {
            EnhancedSettingsSheet()
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        ZStack(alignment: .bottom) {
            // Hero gradient background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            VennColors.coral.opacity(0.4),
                            VennColors.gold.opacity(0.2),
                            VennColors.darkBg
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 280)
                .overlay(
                    // Animated particles
                    ZStack {
                        ForEach(0..<8, id: \.self) { i in
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: CGFloat.random(in: 40...100))
                                .blur(radius: 20)
                                .offset(
                                    x: CGFloat.random(in: -150...150),
                                    y: CGFloat.random(in: -100...100)
                                )
                                .floating(range: CGFloat.random(in: 10...30), duration: Double.random(in: 3...6))
                        }
                    }
                )
                .scaleEffect(1 + (scrollOffset > 0 ? scrollOffset / 500 : 0))
            
            // Profile photo
            VStack(spacing: 16) {
                // Avatar with border
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    VennColors.coral,
                                    VennColors.gold
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(VennColors.darkBg, lineWidth: 4)
                        )
                        .shadow(color: VennColors.coral.opacity(0.4), radius: 20, y: 8)
                    
                    // Edit button
                    Button {
                        HapticManager.shared.impact(.medium)
                        showingEditProfile = true
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(VennColors.coral)
                                    .shadow(color: VennColors.coral.opacity(0.5), radius: 8)
                            )
                    }
                    .offset(x: 4, y: 4)
                }
                
                // Name and username
                VStack(spacing: 6) {
                    Text("Alex Chen")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Text("@alexchen")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(VennColors.textSecondary)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16))
                            .foregroundColor(VennColors.coral)
                    }
                }
            }
            .padding(.bottom, 60)
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(value: "24", label: "Events", icon: "calendar")
            statCard(value: "156", label: "Friends", icon: "person.2.fill")
            statCard(value: "12", label: "Saved", icon: "heart.fill")
        }
        .padding(.horizontal, VennSpacing.xl)
    }
    
    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(VennColors.coral)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(VennColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
        )
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                actionButton(
                    title: "Edit Profile",
                    icon: "person.crop.circle",
                    color: VennColors.coral
                ) {
                    showingEditProfile = true
                }
                
                actionButton(
                    title: "Share Profile",
                    icon: "square.and.arrow.up",
                    color: VennColors.gold
                ) {
                    ToastManager.shared.showInfo("Share profile coming soon!")
                }
            }
            
            HStack(spacing: 12) {
                actionButton(
                    title: "Preferences",
                    icon: "slider.horizontal.3",
                    color: .purple
                ) {
                    ToastManager.shared.showInfo("Preferences coming soon!")
                }
                
                actionButton(
                    title: "Invite Friends",
                    icon: "person.badge.plus",
                    color: .green
                ) {
                    ToastManager.shared.showInfo("Invite friends coming soon!")
                }
            }
        }
        .padding(.horizontal, VennSpacing.xl)
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.shared.impact(.light)
            action()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Achievements
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, VennSpacing.xl)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    achievementBadge(
                        title: "Early Adopter",
                        icon: "star.fill",
                        color: .yellow,
                        unlocked: true
                    )
                    
                    achievementBadge(
                        title: "Social Butterfly",
                        icon: "sparkles",
                        color: VennColors.coral,
                        unlocked: true
                    )
                    
                    achievementBadge(
                        title: "Event Master",
                        icon: "crown.fill",
                        color: .orange,
                        unlocked: false
                    )
                    
                    achievementBadge(
                        title: "VIP",
                        icon: "diamond.fill",
                        color: .purple,
                        unlocked: false
                    )
                }
                .padding(.horizontal, VennSpacing.xl)
            }
        }
    }
    
    private func achievementBadge(title: String, icon: String, color: Color, unlocked: Bool) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        unlocked
                            ? LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(unlocked ? .white : .white.opacity(0.3))
            }
            .shadow(color: unlocked ? color.opacity(0.4) : .clear, radius: 12)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(unlocked ? .white : .white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(width: 90)
        .opacity(unlocked ? 1.0 : 0.6)
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(spacing: 1) {
            settingsRow(title: "Notifications", icon: "bell.fill", color: .red)
            settingsRow(title: "Privacy", icon: "lock.fill", color: .blue)
            settingsRow(title: "Help & Support", icon: "questionmark.circle.fill", color: .green)
            settingsRow(title: "About", icon: "info.circle.fill", color: VennColors.coral)
        }
        .padding(.horizontal, VennSpacing.xl)
    }
    
    private func settingsRow(title: String, icon: String, color: Color) -> some View {
        Button {
            HapticManager.shared.impact(.light)
            ToastManager.shared.showInfo("\(title) coming soon!")
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(VennColors.textTertiary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - Logout Button
    
    private var logoutButton: some View {
        Button {
            HapticManager.shared.impact(.medium)
            ToastManager.shared.showWarning("Logout coming soon!")
        } label: {
            Text("Logout")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .padding(.horizontal, VennSpacing.xl)
    }
}

// MARK: - View Model

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var eventsAttended: Int = 0
    @Published var friendsCount: Int = 0
    @Published var savedEvents: Int = 0
    
    init() {
        // Mock data
        eventsAttended = 24
        friendsCount = 156
        savedEvents = 12
    }
}

// MARK: - Edit Profile Sheet

struct EnhancedEditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                VennColors.darkBg.ignoresSafeArea()
                
                Text("Edit Profile coming soon!")
                    .foregroundColor(.white)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Settings Sheet

struct EnhancedSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                VennColors.darkBg.ignoresSafeArea()
                
                Text("Settings coming soon!")
                    .foregroundColor(.white)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EnhancedProfileView()
        .withToasts()
}
