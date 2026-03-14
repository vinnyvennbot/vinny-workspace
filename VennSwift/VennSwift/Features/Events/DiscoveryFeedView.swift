import SwiftUI

/// Discovery Feed - Main event discovery view
/// Inspired by vennconsumer design with horizontal scrolling cards
struct DiscoveryFeedView: View {
    @StateObject private var viewModel = DiscoveryFeedViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 10/255, green: 8/255, blue: 6/255)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    header
                    
                    // Featured Events (horizontal scroll)
                    if !viewModel.featuredEvents.isEmpty {
                        eventSection(
                            title: "Featured",
                            subtitle: "Curated experiences you'll love",
                            events: viewModel.featuredEvents
                        )
                    }
                    
                    // Tonight's Events
                    if !viewModel.tonightEvents.isEmpty {
                        eventSection(
                            title: "Tonight",
                            subtitle: "Something to do right now",
                            events: viewModel.tonightEvents
                        )
                    }
                    
                    // This Weekend
                    if !viewModel.weekendEvents.isEmpty {
                        eventSection(
                            title: "This Weekend",
                            subtitle: "Plan your perfect Saturday night",
                            events: viewModel.weekendEvents
                        )
                    }
                    
                    // Upcoming
                    if !viewModel.upcomingEvents.isEmpty {
                        eventSection(
                            title: "Coming Soon",
                            subtitle: "Save the date",
                            events: viewModel.upcomingEvents
                        )
                    }
                    
                    // Loading state
                    if viewModel.isLoading {
                        loadingView
                    }
                }
                .padding(.vertical, 24)
            }
        }
        .onAppear {
            viewModel.loadEvents()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 16) {
            // Icon badge
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 14, weight: .semibold))
                Text("Events Calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(0.5)
            }
            .foregroundColor(Color(red: 255/255, green: 127/255, blue: 110/255))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.05))
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Title
            Text("What's ")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
            +
            Text("next")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(Color(red: 255/255, green: 127/255, blue: 110/255))
            
            // Subtitle
            Text("We host curated gatherings weekly. Each event is designed for genuine connection.")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Event Section
    
    private func eventSection(title: String, subtitle: String, events: [DiscoverEvent]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255))
            }
            .padding(.horizontal, 20)
            
            // Horizontal scrolling cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(events) { event in
                        EventCardView(event: event)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Loading
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(Color(red: 255/255, green: 127/255, blue: 110/255))
            
            Text("Finding events...")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255))
        }
        .padding(.vertical, 40)
    }
}

// MARK: - ViewModel

@MainActor
class DiscoveryFeedViewModel: ObservableObject {
    @Published var featuredEvents: [DiscoverEvent] = []
    @Published var tonightEvents: [DiscoverEvent] = []
    @Published var weekendEvents: [DiscoverEvent] = []
    @Published var upcomingEvents: [DiscoverEvent] = []
    @Published var isLoading = false
    
    private let apiBaseURL = "http://localhost:4000" // venn-ai-backend
    
    func loadEvents() {
        // Mock data for now (will connect to backend API later)
        loadMockEvents()
    }
    
    private func loadMockEvents() {
        // Mock featured events
        featuredEvents = [
            DiscoverEvent(
                id: "1",
                name: "Venn Club Dinner",
                dateFormatted: "Feb 28",
                locationShort: "The Barrel Room",
                imageUrl: nil,
                attendees: 17,
                isFeatured: true
            ),
            DiscoverEvent(
                id: "2",
                name: "80s/90s Nostalgia Night",
                dateFormatted: "Mar 15",
                locationShort: "TBD",
                imageUrl: nil,
                attendees: 29,
                isFeatured: true
            )
        ]
        
        // Mock tonight events
        tonightEvents = [
            DiscoverEvent(
                id: "3",
                name: "Silent Disco at Fort Mason",
                dateFormatted: "Tonight, 8PM",
                locationShort: "Fort Mason",
                imageUrl: nil,
                attendees: 45,
                isFeatured: false
            )
        ]
        
        // Mock weekend events
        weekendEvents = [
            DiscoverEvent(
                id: "4",
                name: "Masquerade Ball",
                dateFormatted: "Sat, 9PM",
                locationShort: "Historic Mansion",
                imageUrl: nil,
                attendees: 32,
                isFeatured: false
            ),
            DiscoverEvent(
                id: "5",
                name: "Murder Mystery Yacht",
                dateFormatted: "Sun, 6PM",
                locationShort: "SF Bay",
                imageUrl: nil,
                attendees: 18,
                isFeatured: false
            )
        ]
        
        // Mock upcoming events
        upcomingEvents = [
            DiscoverEvent(
                id: "6",
                name: "Presidio Spring Rodeo",
                dateFormatted: "Mar 29",
                locationShort: "Presidio",
                imageUrl: nil,
                attendees: nil,
                isFeatured: false
            ),
            DiscoverEvent(
                id: "7",
                name: "Spring Yacht Social",
                dateFormatted: "Apr 2026",
                locationShort: "SF Bay",
                imageUrl: nil,
                attendees: nil,
                isFeatured: false
            ),
            DiscoverEvent(
                id: "8",
                name: "Gatsby Garden Party",
                dateFormatted: "May 2026",
                locationShort: "TBD",
                imageUrl: nil,
                attendees: nil,
                isFeatured: false
            )
        ]
    }
    
    // TODO: Connect to backend API
    private func fetchEventsFromAPI() async throws {
        // Will implement when backend API key is available
        guard let url = URL(string: "\(apiBaseURL)/api/events") else { return }
        
        // API call here
    }
}

// MARK: - Preview

#Preview {
    DiscoveryFeedView()
}
