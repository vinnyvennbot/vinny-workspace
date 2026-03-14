import SwiftUI

/// Events Tab - Displays Discovery Feed
struct EventsView: View {
    var body: some View {
        NavigationStack {
            DiscoveryFeedView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        // Empty - title is in the feed itself
                        Text("")
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            // TODO: Filter/search
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(Color(red: 255/255, green: 127/255, blue: 110/255))
                        }
                    }
                }
                .toolbarBackground(Color(red: 10/255, green: 8/255, blue: 6/255), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    EventsView()
}
