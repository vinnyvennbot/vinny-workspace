import SwiftUI

// MARK: - MainTabView
// Snapchat-style swipeable navigation with sliding capsule indicator,
// parallax pill tracking, and premium spring physics.

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    // MARK: Drag state
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    // MARK: Tab bar geometry — populated by PreferenceKey
    @State private var tabFrames: [Int: CGRect] = [:]
    @State private var barWidth: CGFloat = 0

    // Inner padding constants for the tab bar container
    private let barPadH: CGFloat = 5
    private let barPadV: CGFloat = 4

    var body: some View {
        ZStack(alignment: .top) {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                pillTabBar
                    .padding(.top, 4)

                pageStack
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Pill Tab Bar

    private var pillTabBar: some View {
        ZStack(alignment: .leading) {
            // Container
            Capsule()
                .fill(VennColors.surfacePrimary.opacity(0.95))
                .overlay(
                    Capsule()
                        .stroke(VennColors.borderMedium, lineWidth: 0.5)
                )

            // Sliding indicator capsule
            slidingCapsuleIndicator

            // Tab buttons row — each tab gets equal flexible space
            HStack(spacing: 0) {
                ForEach(AppState.Tab.allCases, id: \.rawValue) { tab in
                    tabPill(tab: tab)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, barPadH)
            .padding(.vertical, barPadV)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { barWidth = geo.size.width }
            }
        )
        .coordinateSpace(name: "pillBar")
        .onPreferenceChange(TabFramePreferenceKey.self) { frames in
            tabFrames = frames
        }
        .padding(.horizontal, VennSpacing.xl)
        .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 5)
    }

    // MARK: Sliding capsule indicator

    @ViewBuilder
    private var slidingCapsuleIndicator: some View {
        if let indicatorFrame = computeIndicatorFrame() {
            let isVivi = indicatorTargetTab == .vivi

            Capsule()
                .fill(
                    isVivi
                        ? AnyShapeStyle(VennGradients.primary)
                        : AnyShapeStyle(Color.white)
                )
                .shadow(
                    color: isVivi
                        ? VennColors.coral.opacity(0.40)
                        : Color.white.opacity(0.06),
                    radius: isVivi ? 10 : 4,
                    x: 0,
                    y: 2
                )
                .frame(width: indicatorFrame.width, height: indicatorFrame.height)
                .offset(x: indicatorFrame.minX)
                .animation(isDragging ? .interactiveSpring(response: 0.25) : VennAnimation.snappy, value: indicatorFrame.minX)
                .animation(isDragging ? .interactiveSpring(response: 0.25) : VennAnimation.snappy, value: indicatorFrame.width)
                .animation(VennAnimation.micro, value: isVivi)
        }
    }

    // MARK: Indicator frame computation
    // Linearly interpolates between adjacent tab frames as the user drags.

    private var indicatorTargetTab: AppState.Tab {
        AppState.Tab(rawValue: appState.selectedTab.rawValue) ?? .vivi
    }

    private func computeIndicatorFrame() -> CGRect? {
        let tabs = AppState.Tab.allCases
        let count = tabs.count
        guard count > 0 else { return nil }

        let pageWidth = UIScreen.main.bounds.width
        let rawProgress = CGFloat(appState.selectedTab.rawValue) - dragOffset / pageWidth
        let progress = rawProgress.clamped(to: 0...(CGFloat(count) - 1))

        let lowerIndex = Int(progress)
        let upperIndex = min(lowerIndex + 1, count - 1)
        let fraction = progress - CGFloat(lowerIndex)

        guard
            let lower = tabFrames[lowerIndex],
            let upper = tabFrames[upperIndex]
        else {
            return tabFrames[appState.selectedTab.rawValue]
        }

        let x      = lower.minX + (upper.minX - lower.minX) * fraction
        let width  = lower.width + (upper.width - lower.width) * fraction
        let height = lower.height

        return CGRect(x: x + barPadH, y: barPadV, width: width, height: height)
    }

    // MARK: Individual tab pill

    @ViewBuilder
    private func tabPill(tab: AppState.Tab) -> some View {
        let isSelected = appState.selectedTab == tab
        let isVivi     = tab == .vivi

        Button {
            guard appState.selectedTab != tab else { return }
            withAnimation(VennAnimation.snappy) {
                appState.selectedTab = tab
            }
            Task { @MainActor in
                HapticManager.shared.selectionFeedback()
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .animation(VennAnimation.micro, value: isSelected)

                if isSelected {
                    Text(tab.title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .fixedSize()
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.5, anchor: .leading).combined(with: .opacity),
                                removal:   .scale(scale: 0.5, anchor: .leading).combined(with: .opacity)
                            )
                        )
                }
            }
            .foregroundColor(
                isSelected
                    ? (isVivi ? .white : VennColors.darkBg)
                    : VennColors.textSecondary
            )
            .padding(.horizontal, isSelected ? 12 : 0)
            .padding(.vertical, 8)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: TabFramePreferenceKey.self,
                            value: [tab.rawValue: geo.frame(in: .named("pillBar"))]
                        )
                }
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(VennAnimation.snappy, value: isSelected)
    }

    // MARK: - Page Stack

    private var pageStack: some View {
        GeometryReader { geo in
            let pageWidth = geo.size.width

            HStack(spacing: 0) {
                ForEach(AppState.Tab.allCases, id: \.rawValue) { tab in
                    pageView(for: tab)
                        .frame(width: pageWidth)
                }
            }
            .offset(x: -CGFloat(appState.selectedTab.rawValue) * pageWidth + dragOffset)
            .animation(isDragging ? nil : VennAnimation.standard, value: appState.selectedTab)
            .gesture(
                DragGesture(minimumDistance: 12, coordinateSpace: .local)
                    .onChanged { value in
                        let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                        guard isHorizontal else { return }
                        isDragging = true

                        let raw = value.translation.width
                        let atStart = appState.selectedTab.rawValue == 0 && raw > 0
                        let atEnd   = appState.selectedTab.rawValue == AppState.Tab.allCases.count - 1 && raw < 0

                        if atStart || atEnd {
                            dragOffset = raw * 0.18
                        } else {
                            dragOffset = raw
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        let threshold: CGFloat = pageWidth * 0.22
                        let velocity = value.predictedEndTranslation.width - value.translation.width

                        withAnimation(VennAnimation.standard) {
                            let net = value.translation.width + velocity * 0.55
                            if net < -threshold {
                                let next = min(appState.selectedTab.rawValue + 1, AppState.Tab.allCases.count - 1)
                                let newTab = AppState.Tab(rawValue: next)!
                                if newTab != appState.selectedTab {
                                    appState.selectedTab = newTab
                                    Task { @MainActor in
                                        HapticManager.shared.selectionFeedback()
                                    }
                                }
                            } else if net > threshold {
                                let prev = max(appState.selectedTab.rawValue - 1, 0)
                                let newTab = AppState.Tab(rawValue: prev)!
                                if newTab != appState.selectedTab {
                                    appState.selectedTab = newTab
                                    Task { @MainActor in
                                        HapticManager.shared.selectionFeedback()
                                    }
                                }
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
    }

    // MARK: - Page Content

    @ViewBuilder
    private func pageView(for tab: AppState.Tab) -> some View {
        switch tab {
        case .events:  EventsView()
        case .friends: FriendsView()
        case .vivi:    ViviChatView()
        case .plans:   PlansView()
        case .profile: ProfileView()
        }
    }
}

// MARK: - Preference Key for tab pill frames

private struct TabFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Comparable clamped helper

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager.shared)
}
