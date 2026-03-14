import SwiftUI

/// Events Tab — wraps the discovery feed
struct EventsView: View {
    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()
            DiscoveryFeedView()
        }
    }
}

#Preview {
    EventsView()
}
