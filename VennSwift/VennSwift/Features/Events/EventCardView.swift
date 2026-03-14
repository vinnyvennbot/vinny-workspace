import SwiftUI

/// Event Card - Inspired by vennconsumer design
/// Horizontal scrolling cards with gradient overlays and coral accents
struct EventCardView: View {
    let event: DiscoverEvent
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Background image
            if let imageUrl = event.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(isPressed ? 1.05 : 1.0)
                    case .failure, .empty:
                        placeholderBackground
                    @unknown default:
                        placeholderBackground
                    }
                }
            } else {
                placeholderBackground
            }
            
            // Gradient overlay (dark at bottom for text readability)
            LinearGradient(
                colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content overlay
            VStack(alignment: .leading, spacing: 0) {
                // Status badge (top-left)
                HStack {
                    statusBadge
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                // Event info (bottom)
                VStack(alignment: .leading, spacing: 8) {
                    // Date + Location
                    HStack(spacing: 12) {
                        Label(event.dateFormatted, systemImage: "calendar")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255).opacity(0.8))
                        
                        if let location = event.locationShort {
                            Label(location, systemImage: "mappin")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255).opacity(0.8))
                        }
                    }
                    
                    // Event title
                    Text(event.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
                        .lineLimit(2)
                    
                    // Social proof (if available)
                    if let attendees = event.attendees, attendees > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                            Text("\(attendees) going")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color(red: 255/255, green: 127/255, blue: 110/255)) // Coral
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 340, height: 240) // Aspect ratio ~16:10
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            // Handle tap
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    // MARK: - Components
    
    private var placeholderBackground: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.2), // Coral
                    Color(red: 10/255, green: 8/255, blue: 6/255) // Deep warm black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Coming soon icon
            VStack(spacing: 4) {
                Text("?")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.3))
                
                Text("COMING SOON")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255).opacity(0.5))
            }
        }
    }
    
    private var statusBadge: some View {
        Group {
            if event.isFeatured {
                // Featured badge (coral)
                Text("Featured")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 10/255, green: 8/255, blue: 6/255))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(red: 255/255, green: 127/255, blue: 110/255))
                    )
            } else {
                // Available badge (subtle)
                Text("Available")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .backdrop(Material.ultraThinMaterial)
                    )
            }
        }
    }
    
    private var borderColor: Color {
        if event.isFeatured {
            return Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.5) // Coral
        } else {
            return Color.white.opacity(0.1)
        }
    }
    
    private var borderWidth: CGFloat {
        event.isFeatured ? 2 : 1
    }
}

// MARK: - Event Model

struct DiscoverEvent: Identifiable {
    let id: String
    let name: String
    let dateFormatted: String
    let locationShort: String?
    let imageUrl: String?
    let attendees: Int?
    let isFeatured: Bool
}

// MARK: - Preview

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            EventCardView(event: DiscoverEvent(
                id: "1",
                name: "Venn Club Dinner",
                dateFormatted: "Feb 28",
                locationShort: "SF",
                imageUrl: nil,
                attendees: 24,
                isFeatured: true
            ))
            
            EventCardView(event: DiscoverEvent(
                id: "2",
                name: "Presidio Spring Rodeo",
                dateFormatted: "Mar 2026",
                locationShort: "Presidio",
                imageUrl: nil,
                attendees: 12,
                isFeatured: false
            ))
        }
        .padding(.horizontal)
    }
    .frame(height: 260)
    .background(Color(red: 10/255, green: 8/255, blue: 6/255))
}
