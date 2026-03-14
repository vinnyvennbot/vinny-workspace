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
    }

    // MARK: - Header

    private var friendsHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Friends")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)

                Text("\(mockFriends.count) connections")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(VennColors.textSecondary)
            }

            Spacer()

            Button {
                // TODO: Invite friends
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Invite")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(VennColors.coral)
            }
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
                .foregroundColor(VennColors.textTertiary)

            TextField("", text: $searchQuery, prompt:
                Text("Search friends...").foregroundColor(VennColors.textTertiary)
            )
            .font(.system(size: 16))
            .foregroundColor(VennColors.textPrimary)

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
        )
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
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)

                Text("Try a different name or invite\nsomeone to join Venn")
                    .font(.system(size: 15))
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, VennSpacing.xxxl)
    }
}

// MARK: - Friend Row

struct FriendRow: View {
    let friend: Friend

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
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(VennColors.darkBg, lineWidth: 1.5)
                        )
                }
            }

            // Name + handle
            VStack(alignment: .leading, spacing: 3) {
                Text(friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(VennColors.textPrimary)

                HStack(spacing: 6) {
                    Text(friend.handle)
                        .font(.system(size: 13))
                        .foregroundColor(VennColors.textSecondary)

                    Circle()
                        .fill(VennColors.textTertiary)
                        .frame(width: 2, height: 2)

                    Text("\(friend.mutualCount) mutual")
                        .font(.system(size: 13))
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
    }
}

// MARK: - Preview

#Preview {
    FriendsView()
}
