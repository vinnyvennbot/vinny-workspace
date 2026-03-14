import SwiftUI

/// Event Detail View - Full event page
/// Rich media, RSVP actions, social proof
struct EventDetailView: View {
    let event: DiscoverEvent
    @Environment(\.dismiss) private var dismiss
    @State private var isRSVPed = false
    @State private var showingRSVPSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 10/255, green: 8/255, blue: 6/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero image
                    heroImage
                    
                    // Content
                    VStack(alignment: .leading, spacing: 24) {
                        // Title + date
                        headerSection
                        
                        // Stats bar (attendees, location)
                        statsBar
                        
                        // RSVP button
                        rsvpButton
                        
                        // Description
                        if let description = event.description {
                            descriptionSection(description)
                        }
                        
                        // Attendees preview
                        if let attendees = event.attendees, attendees > 0 {
                            attendeesSection
                        }
                        
                        // Location map preview
                        if event.locationShort != nil {
                            locationSection
                        }
                    }
                    .padding(20)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Success overlay
            if showingRSVPSuccess {
                rsvpSuccessOverlay
            }
        }
        .overlay(alignment: .topLeading) {
            // Back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .backdrop(Material.ultraThinMaterial)
                    )
            }
            .padding(.leading, 20)
            .padding(.top, 54)
        }
    }
    
    // MARK: - Hero Image
    
    private var heroImage: some View {
        ZStack(alignment: .bottom) {
            // Image
            if let imageUrl = event.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        placeholderHero
                    @unknown default:
                        placeholderHero
                    }
                }
            } else {
                placeholderHero
            }
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(red: 10/255, green: 8/255, blue: 6/255).opacity(0.8),
                    Color(red: 10/255, green: 8/255, blue: 6/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 380)
        .clipped()
    }
    
    private var placeholderHero: some View {
        LinearGradient(
            colors: [
                Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.3),
                Color(red: 10/255, green: 8/255, blue: 6/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Event title
            Text(event.name)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
            
            // Date + time
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                Text(event.dateFormatted)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(Color(red: 255/255, green: 127/255, blue: 110/255))
        }
    }
    
    // MARK: - Stats Bar
    
    private var statsBar: some View {
        HStack(spacing: 20) {
            // Attendees
            if let attendees = event.attendees {
                statItem(
                    icon: "person.2.fill",
                    text: "\(attendees) going",
                    color: Color(red: 255/255, green: 127/255, blue: 110/255)
                )
            }
            
            // Location
            if let location = event.locationShort {
                statItem(
                    icon: "mappin.circle.fill",
                    text: location,
                    color: Color(red: 200/255, green: 190/255, blue: 181/255)
                )
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func statItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 15, weight: .medium))
        }
        .foregroundColor(color)
    }
    
    // MARK: - RSVP Button
    
    private var rsvpButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isRSVPed.toggle()
                if isRSVPed {
                    showingRSVPSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showingRSVPSuccess = false
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isRSVPed ? "checkmark.circle.fill" : "calendar.badge.plus")
                    .font(.system(size: 18, weight: .semibold))
                
                Text(isRSVPed ? "You're going!" : "RSVP")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundColor(isRSVPed ? Color(red: 10/255, green: 8/255, blue: 6/255) : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        isRSVPed
                            ? Color(red: 140/255, green: 200/255, blue: 120/255) // Green
                            : LinearGradient(
                                colors: [
                                    Color(red: 255/255, green: 127/255, blue: 110/255),
                                    Color(red: 255/255, green: 191/255, blue: 105/255)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
            )
            .shadow(color: Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.3), radius: 12, y: 4)
        }
    }
    
    // MARK: - Description
    
    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255))
                .lineSpacing(6)
        }
    }
    
    // MARK: - Attendees
    
    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who's going")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
            
            // Mock attendee avatars
            HStack(spacing: -12) {
                ForEach(0..<min(5, event.attendees ?? 0), id: \.self) { _ in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 255/255, green: 127/255, blue: 110/255),
                                    Color(red: 255/255, green: 191/255, blue: 105/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 10/255, green: 8/255, blue: 6/255), lineWidth: 2)
                        )
                }
                
                if let attendees = event.attendees, attendees > 5 {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("+\(attendees - 5)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(red: 10/255, green: 8/255, blue: 6/255), lineWidth: 2)
                        )
                }
            }
        }
    }
    
    // MARK: - Location
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
            
            // Map placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .frame(height: 160)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.5))
                        
                        if let location = event.locationShort {
                            Text(location)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255))
                        }
                    }
                )
        }
    }
    
    // MARK: - RSVP Success Overlay
    
    private var rsvpSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showingRSVPSuccess = false
                    }
                }
            
            VStack(spacing: 16) {
                // Check circle
                ZStack {
                    Circle()
                        .fill(Color(red: 140/255, green: 200/255, blue: 120/255))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("You're going!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
                
                Text("We'll send you event details")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 26/255, green: 22/255, blue: 18/255))
            )
            .padding(40)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Extended DiscoverEvent

extension DiscoverEvent {
    var description: String? {
        // Mock description for now
        return "Join us for an unforgettable evening of connection, music, and genuine moments. This is where magic happens."
    }
}

// MARK: - Preview

#Preview {
    EventDetailView(event: DiscoverEvent(
        id: "1",
        name: "Venn Club Dinner",
        dateFormatted: "Friday, Feb 28 at 7:00 PM",
        locationShort: "The Barrel Room, SF",
        imageUrl: nil,
        attendees: 24,
        isFeatured: true
    ))
}
