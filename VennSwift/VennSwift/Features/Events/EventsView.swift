import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.events.isEmpty {
                    emptyState
                } else {
                    eventsList
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: Filter/search
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .task {
            await viewModel.loadEvents()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No events yet")
                .font(.title2.bold())
            
            Text("Events in your area will appear here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var eventsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.events) { event in
                    EventCard(event: event)
                }
            }
            .padding()
        }
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: Plan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Event Image Placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.2))
                .frame(height: 200)
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange.opacity(0.5))
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.headline)
                
                if let description = event.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label(event.startTime.formatted(date: .abbreviated, time: .shortened), 
                          systemImage: "calendar")
                    
                    if let location = event.location {
                        Label(location, systemImage: "mappin")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                HStack {
                    Text("\(event.attendees.count) attending")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if event.isPublic {
                        Label("Public", systemImage: "globe")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

// MARK: - View Model

@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [Plan] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let networkClient = NetworkClient.shared
    
    func loadEvents() async {
        isLoading = true
        
        do {
            struct EventsResponse: Decodable {
                let events: [Plan]
            }
            
            let response = try await networkClient.request(
                .getEvents,
                as: EventsResponse.self
            )
            self.events = response.events
        } catch {
            self.error = error
            print("Error loading events: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

#Preview {
    EventsView()
}
