import SwiftUI

/// Enhanced Friends View - Premium social connections
/// Features: Friend discovery, mutual friends, activity feed, invites
struct EnhancedFriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var searchText = ""
    @State private var showingInvite = false
    @State private var selectedTab: FriendTab = .all
    
    enum FriendTab: String, CaseIterable {
        case all = "All"
        case mutual = "Mutual"
        case pending = "Pending"
        
        var icon: String {
            switch self {
            case .all: return "person.2.fill"
            case .mutual: return "star.fill"
            case .pending: return "clock.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with search
                friendsHeader
                
                // Tab selector
                tabSelector
                
                // Friends list
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        if filteredFriends.isEmpty {
                            emptyState
                        } else {
                            ForEach(Array(filteredFriends.enumerated()), id: \.element.id) { index, friend in
                                FriendCard(friend: friend, index: index)
                                    .scrollScale(
                                        from: 0.95,
                                        to: 1.0,
                                        threshold: 300,
                                        scrollOffset: $scrollOffset
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, VennSpacing.lg)
                    .padding(.top, VennSpacing.md)
                    .padding(.bottom, 100)
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
            
            // Floating add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button {
                        HapticManager.shared.impact(.medium)
                        showingInvite = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [VennColors.coral, VennColors.gold],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: VennColors.coral.opacity(0.5), radius: 20, y: 8)
                            )
                    }
                    .padding(.trailing, VennSpacing.xl)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingInvite) {
            InviteFriendSheet()
        }
        .withToasts()
    }
    
    private var filteredFriends: [EnhancedFriend] {
        var friends = viewModel.friends
        
        switch selectedTab {
        case .all:
            break
        case .mutual:
            friends = friends.filter { $0.mutualFriends > 0 }
        case .pending:
            friends = friends.filter { $0.isPending }
        }
        
        if !searchText.isEmpty {
            friends = friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return friends
    }
    
    // MARK: - Header
    
    private var friendsHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Friends")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.friends.count)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.textSecondary)
            }
            
            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(VennColors.textTertiary)
                
                TextField("Search friends...", text: $searchText)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white)
                    .tint(VennColors.coral)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        HapticManager.shared.impact(.light)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(VennColors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 8) {
            ForEach(FriendTab.allCases, id: \.self) { tab in
                Button {
                    HapticManager.shared.impact(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 13, weight: .bold))
                        
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(selectedTab == tab ? .white : VennColors.textTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                selectedTab == tab
                                    ? LinearGradient(
                                        colors: [VennColors.coral, VennColors.gold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.white.opacity(0.05)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.vertical, 8)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(VennColors.textTertiary)
                .padding(.top, 80)
            
            VStack(spacing: 8) {
                Text("No friends yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Start connecting with people at events")
                    .font(.system(size: 15))
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                HapticManager.shared.impact(.medium)
                showingInvite = true
            } label: {
                Text("Invite Friends")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [VennColors.coral, VennColors.gold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - Friend Card

struct FriendCard: View {
    let friend: EnhancedFriend
    let index: Int
    
    @State private var appeared = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [VennColors.coral, VennColors.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                if friend.hasProfilePhoto {
                    // Placeholder for actual photo
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 56, height: 56)
                }
                
                if friend.isOnline {
                    Circle()
                        .fill(VennColors.success)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(VennColors.darkBg, lineWidth: 2)
                        )
                        .offset(x: 20, y: 20)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(friend.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if friend.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(VennColors.coral)
                    }
                }
                
                if friend.mutualFriends > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                        Text("\(friend.mutualFriends) mutual")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(VennColors.textSecondary)
                } else {
                    Text(friend.username)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(VennColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Action button
            if friend.isPending {
                HStack(spacing: 8) {
                    Button {
                        HapticManager.shared.impact(.medium)
                        ToastManager.shared.showSuccess("Friend request accepted!")
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.green)
                            )
                    }
                    
                    Button {
                        HapticManager.shared.impact(.light)
                        ToastManager.shared.showInfo("Friend request declined")
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.8))
                            )
                    }
                }
            } else {
                Button {
                    HapticManager.shared.impact(.light)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(VennColors.textTertiary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .pressScale(isPressed: $isPressed, scale: 0.98)
        .onTapGesture {
            isPressed.toggle()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.05)) {
                appeared = true
            }
        }
    }
}

// MARK: - Friend Model

struct EnhancedFriend: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let mutualFriends: Int
    let isOnline: Bool
    let isVerified: Bool
    let isPending: Bool
    let hasProfilePhoto: Bool
}

// MARK: - View Model

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [EnhancedFriend] = []
    
    init() {
        loadMockFriends()
    }
    
    private func loadMockFriends() {
        friends = [
            EnhancedFriend(name: "Sarah Chen", username: "@sarahc", mutualFriends: 12, isOnline: true, isVerified: true, isPending: false, hasProfilePhoto: true),
            EnhancedFriend(name: "Mike Johnson", username: "@mikej", mutualFriends: 8, isOnline: false, isVerified: false, isPending: false, hasProfilePhoto: true),
            EnhancedFriend(name: "Emma Davis", username: "@emmad", mutualFriends: 15, isOnline: true, isVerified: true, isPending: false, hasProfilePhoto: true),
            EnhancedFriend(name: "Alex Rivera", username: "@alexr", mutualFriends: 0, isOnline: false, isVerified: false, isPending: true, hasProfilePhoto: false),
            EnhancedFriend(name: "Lisa Wong", username: "@lisaw", mutualFriends: 24, isOnline: true, isVerified: true, isPending: false, hasProfilePhoto: true),
            EnhancedFriend(name: "Tom Martinez", username: "@tomm", mutualFriends: 6, isOnline: false, isVerified: false, isPending: false, hasProfilePhoto: false),
            EnhancedFriend(name: "Nina Patel", username: "@ninap", mutualFriends: 0, isOnline: true, isVerified: false, isPending: true, hasProfilePhoto: true)
        ]
    }
}

// MARK: - Invite Sheet

struct InviteFriendSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                VennColors.darkBg.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(VennColors.coral)
                    
                    Text("Invite friends coming soon!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .navigationTitle("Invite Friends")
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
    EnhancedFriendsView()
}
