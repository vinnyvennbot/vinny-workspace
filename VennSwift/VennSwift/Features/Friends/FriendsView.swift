import SwiftUI

struct FriendsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Placeholder
                    Image(systemName: "person.2")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("Friends")
                        .font(.title2.bold())
                    
                    Text("Connect with friends and make new ones")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Friends")
        }
    }
}

#Preview {
    FriendsView()
}
