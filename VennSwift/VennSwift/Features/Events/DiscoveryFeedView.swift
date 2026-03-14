import SwiftUI

// MARK: - Discovery Feed View

struct DiscoveryFeedView: View {
    @StateObject private var viewModel = DiscoveryFeedViewModel()

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VennSpacing.xxxl) {
                    feedHeader
                        .padding(.horizontal, VennSpacing.xl)

                    if viewModel.isLoading {
                        loadingView
                    }

                    if !viewModel.featuredEvents.isEmpty {
                        feedSection(
                            title: "Featured",
                            subtitle: "Curated experiences you'll love",
                            events: viewModel.featuredEvents
                        )
                    }

                    if !viewModel.tonightEvents.isEmpty {
                        feedSection(
                            title: "Tonight",
                            subtitle: "Something to do right now",
                            events: viewModel.tonightEvents
                        )
                    }

                    if !viewModel.weekendEvents.isEmpty {
                        feedSection(
                            title: "This Weekend",
                            subtitle: "Plan your perfect Saturday",
                            events: viewModel.weekendEvents
                        )
                    }

                    if !viewModel.upcomingEvents.isEmpty {
                        feedSection(
                            title: "Coming Soon",
                            subtitle: "Save the date",
                            events: viewModel.upcomingEvents
                        )
                    }
                }
                .padding(.top, VennSpacing.xxl)
                .padding(.bottom, VennSpacing.huge)
            }
        }
        .onAppear {
            viewModel.loadEvents()
        }
    }

    // MARK: - Header

    private var feedHeader: some View {
        VStack(alignment: .leading, spacing: VennSpacing.xs) {
            Text("Discover")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(VennColors.textPrimary)

            Text("Curated for you")
                .font(VennTypography.body)
                .foregroundColor(VennColors.textSecondary)
        }
    }

    // MARK: - Section

    private func feedSection(title: String, subtitle: String, events: [DiscoverEvent]) -> some View {
        VStack(alignment: .leading, spacing: VennSpacing.md) {
            VStack(alignment: .leading, spacing: VennSpacing.xs) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(VennColors.textSecondary)
            }
            .padding(.horizontal, VennSpacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
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

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: VennColors.coral))
            Spacer()
        }
        .padding(.vertical, VennSpacing.xl)
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
        loadMockEvents()
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
            DiscoverEvent(id: "4", name: "Masquerade Ball",     dateFormatted: "Sat, 9PM",  locationShort: "Historic Mansion", imageUrl: nil, attendees: 32, isFeatured: false),
            DiscoverEvent(id: "5", name: "Murder Mystery Yacht", dateFormatted: "Sun, 6PM",  locationShort: "SF Bay",           imageUrl: nil, attendees: 18, isFeatured: false)
        ]

        upcomingEvents = [
            DiscoverEvent(id: "6", name: "Presidio Spring Rodeo", dateFormatted: "Mar 29",    locationShort: "Presidio",  imageUrl: nil, attendees: nil, isFeatured: false),
            DiscoverEvent(id: "7", name: "Spring Yacht Social",   dateFormatted: "Apr 2026",  locationShort: "SF Bay",    imageUrl: nil, attendees: nil, isFeatured: false),
            DiscoverEvent(id: "8", name: "Gatsby Garden Party",   dateFormatted: "May 2026",  locationShort: "TBD",       imageUrl: nil, attendees: nil, isFeatured: false)
        ]
    }

    // TODO: Connect to backend API
    private func fetchEventsFromAPI() async throws {
        guard let url = URL(string: "\(apiBaseURL)/api/events") else { return }
        // API call here
        _ = url
    }
}

// MARK: - Preview

#Preview {
    DiscoveryFeedView()
}
