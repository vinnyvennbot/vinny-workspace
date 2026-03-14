import SwiftUI

// MARK: - Mock Friend Model

struct Friend: Identifiable {
    let id: String
    let name: String
    let handle: String
    let mutualCount: Int
    let isOnline: Bool
    let avatarGradient: [Color]
}

private let mockFriends: [Friend] = [
    Friend(id: "1", name: "Maya Chen",     handle: "@mayac",    mutualCount: 6,  isOnline: true,  avatarGradient: [Color(red: 255/255, green: 127/255, blue: 110/255), Color(red: 255/255, green: 185/255, blue: 106/255)]),
    Friend(id: "2", name: "Luca Rossi",    handle: "@luca_r",   mutualCount: 3,  isOnline: false, avatarGradient: [Color(red: 100/255, green: 160/255, blue: 240/255), Color(red: 140/255, green: 200/255, blue: 255/255)]),
    Friend(id: "3", name: "Priya Nair",    handle: "@priya.n",  mutualCount: 8,  isOnline: true,  avatarGradient: [Color(red: 200/255, green: 130/255, blue: 255/255), Color(red: 255/255, green: 185/255, blue: 106/255)]),
    Friend(id: "4", name: "Sam Wolfe",     handle: "@samwolfe", mutualCount: 2,  isOnline: false, avatarGradient: [Color(red: 140/255, green: 200/255, blue: 120/255), Color(red: 100/255, green: 220/255, blue: 160/255)]),
    Friend(id: "5", name: "Ari Goldman",   handle: "@ari_g",    mutualCount: 11, isOnline: true,  avatarGradient: [Color(red: 255/255, green: 185/255, blue: 106/255), Color(red: 255/255, green: 127/255, blue: 110/255)]),
    Friend(id: "6", name: "Jordan Park",   handle: "@jpark",    mutualCount: 4,  isOnline: false, avatarGradient: [Color(red: 240/255, green: 100/255, blue: 150/255), Color(red: 255/255, green: 160/255, blue: 180/255)])
]

// MARK: - FriendsView

struct FriendsView: View {
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool
    @State private var listAppeared = false
    @State private var displayedCount = 0

    private var filteredFriends: [Friend] {
        if searchQuery.isEmpty { return mockFriends }
        return mockFriends.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.handle.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                friendsHeader

                searchBar
                    .padding(.horizontal, VennSpacing.xl)
                    .padding(.top, VennSpacing.lg)
                    .padding(.bottom, VennSpacing.sm)

                if filteredFriends.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(filteredFriends.enumerated()), id: \.element.id) { index, friend in
                                FriendRow(friend: friend)
                                    .opacity(listAppeared ? 1 : 0)
                                    .offset(y: listAppeared ? 0 : 16)
                                    .animation(
                                        VennAnimation.standard.delay(Double(index) * 0.06),
                                        value: listAppeared
                                    )

                                if index < filteredFriends.count - 1 {
                                    Rectangle()
                                        .fill(VennColors.borderSubtle)
                                        .frame(height: 0.5)
                                        .padding(.leading, 74)
                                }
                            }
                        }
                        .padding(.top, VennSpacing.sm)
                        .padding(.bottom, VennSpacing.xxxl)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(VennAnimation.gentle) {
                listAppeared = true
            }
            // Animate the member count counter
            animateCounter()
        }
    }

    // MARK: - Counter Animation

    private func animateCounter() {
        let target = mockFriends.count
        let steps = target
        let interval = 0.04
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                displayedCount = i
            }
        }
    }

    // MARK: - Header

    private var friendsHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Friends")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)

                Text("\(displayedCount) connections")
                    .font(VennTypography.buttonSmall)
                    .foregroundColor(VennColors.textSecondary)
            }

            Spacer()

            InviteButton()
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.top, VennSpacing.xl)
        .padding(.bottom, VennSpacing.xs)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSearchFocused ? VennColors.coral : VennColors.textTertiary)
                .animation(VennAnimation.micro, value: isSearchFocused)

            TextField("", text: $searchQuery, prompt:
                Text("Search friends...").foregroundColor(VennColors.textTertiary)
            )
            .font(VennTypography.bodyLarge)
            .foregroundColor(VennColors.textPrimary)
            .focused($isSearchFocused)

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(VennColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, VennSpacing.lg)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                .fill(VennColors.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                        .stroke(
                            isSearchFocused ? VennColors.coral.opacity(0.55) : VennColors.borderMedium,
                            lineWidth: isSearchFocused ? 1.5 : 1
                        )
                )
        )
        .scaleEffect(isSearchFocused ? 1.01 : 1.0)
        .animation(VennAnimation.micro, value: isSearchFocused)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: VennSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(VennColors.coralSubtle)
                    .frame(width: 100, height: 100)

                Image(systemName: "person.2.slash")
                    .font(.system(size: 40))
                    .foregroundColor(VennColors.coral.opacity(0.5))
            }

            VStack(spacing: VennSpacing.sm) {
                Text("No friends found")
                    .font(VennTypography.subheading)
                    .foregroundColor(VennColors.textPrimary)

                Text("Try a different name or invite\nsomeone to join Venn")
                    .font(VennTypography.body)
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, VennSpacing.xxxl)
    }
}

// MARK: - Invite Button

private struct InviteButton: View {
    @State private var isPressed = false

    var body: some View {
        ShareLink(item: "Join me on Venn! Download at venn.app/invite") {
            HStack(spacing: 5) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                Text("Invite")
                    .font(VennTypography.buttonSmall)
            }
            .foregroundColor(.white)
            .padding(.horizontal, VennSpacing.md)
            .padding(.vertical, VennSpacing.xs + 2)
            .background(
                Capsule()
                    .fill(VennGradients.primary)
                    .shadow(
                        color: VennColors.coral.opacity(0.35),
                        radius: 8,
                        x: 0,
                        y: 3
                    )
            )
        }
        .simultaneousGesture(TapGesture().onEnded {
            HapticManager.shared.impact(.light)
        })
        .pressScale(isPressed: $isPressed, scale: 0.95, haptic: nil)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Friend Row

struct FriendRow: View {
    let friend: Friend
    @State private var isPressed = false
    @State private var showingProfile = false

    var body: some View {
        HStack(spacing: 14) {
            // Avatar with online indicator
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: friend.avatarGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(friend.name.prefix(1)))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )

                if friend.isOnline {
                    Circle()
                        .fill(VennColors.success)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(VennColors.darkBg, lineWidth: 2)
                        )
                        .pulse(from: 0.85, to: 1.15, duration: 1.5)
                }
            }

            // Name + handle
            VStack(alignment: .leading, spacing: 3) {
                Text(friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(VennColors.textPrimary)

                HStack(spacing: 6) {
                    Text(friend.handle)
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textSecondary)

                    Circle()
                        .fill(VennColors.textTertiary)
                        .frame(width: 2, height: 2)

                    Text("\(friend.mutualCount) mutual")
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(VennColors.textTertiary)
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            HapticManager.shared.impact(.light)
            showingProfile = true
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                HapticManager.shared.impact(.light)
                // Message action — open friend profile sheet to the message button
                showingProfile = true
            } label: {
                Label("Message", systemImage: "message.fill")
            }
            .tint(VennColors.indigo)
        }
        .sheet(isPresented: $showingProfile) {
            FriendProfileSheet(friend: friend)
        }
    }
}

// MARK: - Friend Profile Sheet

private struct FriendProfileSheet: View {
    let friend: Friend
    @Environment(\.dismiss) private var dismiss
    @State private var showRemoveAlert = false

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
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.top, VennSpacing.xl)
                .padding(.bottom, VennSpacing.lg)

                VStack(spacing: VennSpacing.xxl) {
                    // Avatar + identity card
                    VStack(spacing: VennSpacing.lg) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: friend.avatarGradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 84, height: 84)
                                .overlay(
                                    Text(String(friend.name.prefix(1)))
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                )

                            if friend.isOnline {
                                Circle()
                                    .fill(VennColors.success)
                                    .frame(width: 16, height: 16)
                                    .overlay(Circle().stroke(VennColors.darkBg, lineWidth: 2.5))
                            }
                        }

                        VStack(spacing: VennSpacing.xs) {
                            Text(friend.name)
                                .font(VennTypography.subheading)
                                .foregroundColor(VennColors.textPrimary)

                            Text(friend.handle)
                                .font(VennTypography.body)
                                .foregroundColor(VennColors.textSecondary)

                            Text(friend.isOnline ? "Online now" : "Offline")
                                .font(VennTypography.captionBold)
                                .foregroundColor(friend.isOnline ? VennColors.success : VennColors.textTertiary)
                                .padding(.horizontal, VennSpacing.md)
                                .padding(.vertical, VennSpacing.xs)
                                .background(
                                    Capsule()
                                        .fill(friend.isOnline ? VennColors.success.opacity(0.12) : VennColors.surfaceTertiary)
                                )
                        }
                    }

                    // Mutual events stat
                    HStack(spacing: 0) {
                        VStack(spacing: VennSpacing.xs) {
                            Text("\(friend.mutualCount)")
                                .font(VennTypography.subheading)
                                .foregroundColor(VennColors.textPrimary)
                            Text("Mutual\nEvents")
                                .font(VennTypography.caption)
                                .foregroundColor(VennColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, VennSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                            .fill(VennColors.surfacePrimary)
                    )
                    .padding(.horizontal, VennSpacing.xl)

                    // Action buttons
                    VStack(spacing: VennSpacing.md) {
                        Button {
                            HapticManager.shared.impact(.medium)
                            dismiss()
                        } label: {
                            HStack(spacing: VennSpacing.sm) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Message")
                                    .font(VennTypography.buttonLabel)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                Capsule()
                                    .fill(VennGradients.primary)
                            )
                        }

                        Button {
                            HapticManager.shared.impact(.medium)
                            showRemoveAlert = true
                        } label: {
                            HStack(spacing: VennSpacing.sm) {
                                Image(systemName: "person.badge.minus")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Remove Friend")
                                    .font(VennTypography.buttonLabel)
                            }
                            .foregroundColor(VennColors.error)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                Capsule()
                                    .fill(VennColors.error.opacity(0.10))
                            )
                        }
                    }
                    .padding(.horizontal, VennSpacing.xl)
                }

                Spacer()
            }
        }
        .alert("Remove Friend", isPresented: $showRemoveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                HapticManager.shared.impact(.medium)
                dismiss()
            }
        } message: {
            Text("Remove \(friend.name) from your friends?")
        }
    }
}

// MARK: - Preview

#Preview {
    FriendsView()
}
