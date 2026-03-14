import SwiftUI

// MARK: - Discovery Feed View

struct DiscoveryFeedView: View {
    @StateObject private var viewModel = DiscoveryFeedViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var isRefreshing = false

    // Staggered section visibility - one flag per section
    @State private var showFeatured  = false
    @State private var showTonight   = false
    @State private var showWeekend   = false
    @State private var showUpcoming  = false

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VennSpacing.xxxl) {
                    // Pull to refresh indicator
                    if isRefreshing {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: VennColors.coral))
                                .scaleEffect(0.8)
                            Spacer()
                        }
                        .padding(.top, VennSpacing.md)
                        .transition(.opacity.combined(with: .scale))
                    }

                    // Discover header - subtle parallax driven by scroll offset
                    feedHeader
                        .padding(.horizontal, VennSpacing.xl)
                        .offset(y: max(-scrollOffset * 0.3, -20))
                        .animation(VennAnimation.gentle, value: scrollOffset)

                    if viewModel.isLoading && viewModel.featuredEvents.isEmpty {
                        loadingSkeletons
                    }

                    if !viewModel.featuredEvents.isEmpty {
                        feedSection(
                            title: "Featured",
                            subtitle: "Curated experiences you'll love",
                            events: viewModel.featuredEvents,
                            sectionTag: "featured"
                        )
                        .opacity(showFeatured ? 1 : 0)
                        .offset(y: showFeatured ? 0 : 12)
                        .animation(VennAnimation.standard.delay(0.05), value: showFeatured)
                    }

                    if !viewModel.tonightEvents.isEmpty {
                        feedSection(
                            title: "Tonight",
                            subtitle: "Something to do right now",
                            events: viewModel.tonightEvents,
                            sectionTag: "tonight"
                        )
                        .opacity(showTonight ? 1 : 0)
                        .offset(y: showTonight ? 0 : 12)
                        .animation(VennAnimation.standard.delay(0.12), value: showTonight)
                    }

                    if !viewModel.weekendEvents.isEmpty {
                        feedSection(
                            title: "This Weekend",
                            subtitle: "Plan your perfect Saturday",
                            events: viewModel.weekendEvents,
                            sectionTag: "weekend"
                        )
                        .opacity(showWeekend ? 1 : 0)
                        .offset(y: showWeekend ? 0 : 12)
                        .animation(VennAnimation.standard.delay(0.20), value: showWeekend)
                    }

                    if !viewModel.upcomingEvents.isEmpty {
                        feedSection(
                            title: "Coming Soon",
                            subtitle: "Save the date",
                            events: viewModel.upcomingEvents,
                            sectionTag: "upcoming"
                        )
                        .opacity(showUpcoming ? 1 : 0)
                        .offset(y: showUpcoming ? 0 : 12)
                        .animation(VennAnimation.standard.delay(0.28), value: showUpcoming)
                    }
                }
                .padding(.top, VennSpacing.xl)
                .padding(.bottom, VennSpacing.huge)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value

                // Pull-to-refresh trigger
                if value > 100 && !isRefreshing && !viewModel.isLoading {
                    triggerRefresh()
                }
            }
        }
        .onAppear {
            viewModel.loadEvents()
        }
        .onChange(of: viewModel.isLoading) { _, loading in
            // Stagger sections in once data arrives
            if !loading {
                showFeatured = true
                showTonight  = true
                showWeekend  = true
                showUpcoming = true
            }
        }
    }

    // MARK: - Actions

    private func triggerRefresh() {
        withAnimation(VennAnimation.standard) {
            isRefreshing = true
        }

        // Premium: double-pulse - light on pull, success on complete
        Task { @MainActor in
            HapticManager.shared.impact(.light)
        }

        // Reset stagger flags so sections re-animate in on refresh
        showFeatured = false
        showTonight  = false
        showWeekend  = false
        showUpcoming = false

        Task {
            await viewModel.refresh()

            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 s minimum feel

            await MainActor.run {
                withAnimation(VennAnimation.standard) {
                    isRefreshing = false
                }
                HapticManager.shared.success()

                // Stagger sections back in after refresh
                showFeatured = true
                showTonight  = true
                showWeekend  = true
                showUpcoming = true
            }
        }
    }

    // MARK: - Header

    private var feedHeader: some View {
        VStack(alignment: .leading, spacing: VennSpacing.xs) {
            Text("Discover")
                .font(VennTypography.heading)
                .foregroundColor(VennColors.textPrimary)

            Text("Curated for you")
                .font(VennTypography.body)
                .foregroundColor(VennColors.textSecondary)
        }
    }

    // MARK: - Section

    private func feedSection(
        title: String,
        subtitle: String,
        events: [DiscoverEvent],
        sectionTag: String
    ) -> some View {
        VStack(alignment: .leading, spacing: VennSpacing.md) {
            // Header row: accent line + title + "See all"
            HStack(alignment: .top) {
                // Coral accent line
                RoundedRectangle(cornerRadius: VennRadius.small)
                    .fill(VennColors.coral)
                    .frame(width: 3, height: 36)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: VennSpacing.xs) {
                    Text(title)
                        .font(VennTypography.subheading)
                        .foregroundColor(VennColors.textPrimary)

                    Text(subtitle)
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textSecondary)
                }

                Spacer()

                Button {
                    Task { @MainActor in
                        HapticManager.shared.selectionFeedback()
                    }
                    // TODO: navigate to filtered section list
                } label: {
                    Text("See all")
                        .font(VennTypography.captionBold)
                        .foregroundColor(VennColors.coral)
                        .padding(.horizontal, VennSpacing.sm)
                        .padding(.vertical, VennSpacing.xs)
                        .background(
                            Capsule()
                                .fill(VennColors.coralSubtle)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, VennSpacing.xs)
            }
            .padding(.horizontal, VennSpacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VennSpacing.md + 2) {
                    ForEach(events) { event in
                        EventCardView(event: event)
                    }
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.vertical, VennSpacing.xs)
            }
        }
    }

    // MARK: - Loading

    private var loadingSkeletons: some View {
        VStack(alignment: .leading, spacing: VennSpacing.xxxl) {
            // Featured section skeleton
            VStack(alignment: .leading, spacing: VennSpacing.md) {
                VStack(alignment: .leading, spacing: VennSpacing.xs) {
                    SkeletonView(width: 120, height: 24, cornerRadius: VennRadius.small)
                    SkeletonView(width: 200, height: 16, cornerRadius: VennRadius.small - 2)
                }
                .padding(.horizontal, VennSpacing.xl)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VennSpacing.md + 2) {
                        ForEach(0..<2, id: \.self) { _ in
                            SkeletonEventCard()
                        }
                    }
                    .padding(.horizontal, VennSpacing.xl)
                }
            }

            // Tonight section skeleton
            VStack(alignment: .leading, spacing: VennSpacing.md) {
                VStack(alignment: .leading, spacing: VennSpacing.xs) {
                    SkeletonView(width: 80, height: 24, cornerRadius: VennRadius.small)
                    SkeletonView(width: 180, height: 16, cornerRadius: VennRadius.small - 2)
                }
                .padding(.horizontal, VennSpacing.xl)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VennSpacing.md + 2) {
                        SkeletonEventCard()
                    }
                    .padding(.horizontal, VennSpacing.xl)
                }
            }
        }
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - ViewModel

@MainActor
class DiscoveryFeedViewModel: ObservableObject {
    @Published var featuredEvents: [DiscoverEvent] = []
    @Published var tonightEvents:  [DiscoverEvent] = []
    @Published var weekendEvents:  [DiscoverEvent] = []
    @Published var upcomingEvents: [DiscoverEvent] = []
    @Published var isLoading = false

    private let apiBaseURL = "http://localhost:4000" // venn-ai-backend

    func loadEvents() {
        Task {
            isLoading = true
            
            do {
                // Try to fetch from API
                let events = try await APIClient.shared.fetchEvents(city: "sf", limit: 50)
                
                // Categorize events
                categorizeEvents(events)
                
            } catch {
                // Fallback to mock data on error
                print("Failed to load events from API: \(error)")
                loadMockEvents()
            }
            
            isLoading = false
        }
    }
    
    func refresh() async {
        do {
            let events = try await APIClient.shared.fetchEvents(city: "sf", limit: 50)
            categorizeEvents(events)
        } catch {
            // Keep existing events on refresh error
            print("Failed to refresh events: \(error)")
        }
    }
    
    private func categorizeEvents(_ events: [DiscoverEvent]) {
        // Simple categorization - in production this would be smarter
        featuredEvents = Array(events.filter { $0.isFeatured }.prefix(5))
        tonightEvents = Array(events.filter { isTonight($0) }.prefix(3))
        weekendEvents = Array(events.filter { isThisWeekend($0) }.prefix(4))
        upcomingEvents = Array(events.filter { !isTonight($0) && !isThisWeekend($0) }.prefix(6))
        
        // If no events in a category, fill from general pool
        if featuredEvents.isEmpty { featuredEvents = Array(events.prefix(2)) }
        if tonightEvents.isEmpty { tonightEvents = [] }
        if weekendEvents.isEmpty { weekendEvents = [] }
        if upcomingEvents.isEmpty { upcomingEvents = Array(events.prefix(5)) }
    }
    
    private func isTonight(_ event: DiscoverEvent) -> Bool {
        // Simplified - check if date string contains "Tonight"
        return event.dateFormatted.contains("Tonight")
    }
    
    private func isThisWeekend(_ event: DiscoverEvent) -> Bool {
        // Simplified - check if date string suggests weekend
        let weekendKeywords = ["Sat", "Sun", "Weekend"]
        return weekendKeywords.contains { event.dateFormatted.contains($0) }
    }

    private func loadMockEvents() {
        featuredEvents = [
            DiscoverEvent(id: "1", name: "Venn Club Dinner",       dateFormatted: "Feb 28",       locationShort: "The Barrel Room", imageUrl: nil, attendees: 17, isFeatured: true),
            DiscoverEvent(id: "2", name: "80s/90s Nostalgia Night", dateFormatted: "Mar 15",       locationShort: "TBD",             imageUrl: nil, attendees: 29, isFeatured: true)
        ]

        tonightEvents = [
            DiscoverEvent(id: "3", name: "Silent Disco at Fort Mason", dateFormatted: "Tonight, 8PM", locationShort: "Fort Mason", imageUrl: nil, attendees: 45, isFeatured: false)
        ]

        weekendEvents = [
            DiscoverEvent(id: "4", name: "Masquerade Ball",      dateFormatted: "Sat, 9PM", locationShort: "Historic Mansion", imageUrl: nil, attendees: 32, isFeatured: false),
            DiscoverEvent(id: "5", name: "Murder Mystery Yacht", dateFormatted: "Sun, 6PM", locationShort: "SF Bay",           imageUrl: nil, attendees: 18, isFeatured: false)
        ]

        upcomingEvents = [
            DiscoverEvent(id: "6", name: "Presidio Spring Rodeo", dateFormatted: "Mar 29",   locationShort: "Presidio", imageUrl: nil, attendees: nil, isFeatured: false),
            DiscoverEvent(id: "7", name: "Spring Yacht Social",   dateFormatted: "Apr 2026", locationShort: "SF Bay",   imageUrl: nil, attendees: nil, isFeatured: false),
            DiscoverEvent(id: "8", name: "Gatsby Garden Party",   dateFormatted: "May 2026", locationShort: "TBD",      imageUrl: nil, attendees: nil, isFeatured: false)
        ]
    }

    // TODO: Connect to backend API
    private func fetchEventsFromAPI() async throws {
        guard let url = URL(string: "\(apiBaseURL)/api/events") else { return }
        _ = url
    }
}

// MARK: - Preview

#Preview {
    DiscoveryFeedView()
}
