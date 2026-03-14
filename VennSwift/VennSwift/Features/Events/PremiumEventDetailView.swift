import SwiftUI

/// PREMIUM Event Detail View - Stunning full-screen experience
/// Features: Hero transitions, parallax, haptics, glass-morphism, advanced gestures
struct PremiumEventDetailView: View {
    let event: DiscoverEvent
    var namespace: Namespace.ID
    
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var isRSVPed = false
    @State private var showingSuccess = false
    @State private var dragOffset: CGFloat = 0
    @GestureState private var gestureOffset: CGFloat = 0
    
    // Parallax and blur effects
    private var headerOpacity: Double {
        min(max(scrollOffset / 200, 0), 1)
    }
    
    private var imageScale: CGFloat {
        let scale = 1 + (scrollOffset > 0 ? scrollOffset / 1000 : 0)
        return max(scale, 1)
    }
    
    private var imageOffset: CGFloat {
        scrollOffset > 0 ? -scrollOffset * 0.5 : 0
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 10/255, green: 8/255, blue: 6/255)
                .ignoresSafeArea()
            
            // Main content
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero image with parallax
                        heroSection(geometry: geometry)
                        
                        // Content
                        contentSection
                            .background(Color(red: 10/255, green: 8/255, blue: 6/255))
                    }
                    .background(
                        GeometryReader { scrollGeo in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: scrollGeo.frame(in: .named("scroll")).minY)
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
            }
            
            // Floating header (appears on scroll)
            floatingHeader
            
            // Floating RSVP button
            floatingRSVPButton
            
            // Close button
            closeButton
            
            // Success overlay
            if showingSuccess {
                successOverlay
            }
        }
        .gesture(
            DragGesture()
                .updating($gestureOffset) { value, state, _ in
                    if value.translation.height > 0 {
                        state = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 200 {
                        HapticManager.shared.impact(.medium)
                        dismiss()
                    }
                }
        )
        .offset(y: gestureOffset)
    }
    
    // MARK: - Hero Section
    
    private func heroSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            // Background image with parallax
            Group {
                if let imageUrl = event.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            premiumPlaceholder
                        @unknown default:
                            premiumPlaceholder
                        }
                    }
                } else {
                    premiumPlaceholder
                }
            }
            .frame(width: geometry.size.width, height: 500)
            .scaleEffect(imageScale)
            .offset(y: imageOffset)
            .clipped()
            
            // Gradient overlays
            VStack(spacing: 0) {
                // Top fade
                LinearGradient(
                    colors: [
                        Color(red: 10/255, green: 8/255, blue: 6/255).opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 150)
                
                Spacer()
                
                // Bottom fade
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(red: 10/255, green: 8/255, blue: 6/255).opacity(0.6),
                        Color(red: 10/255, green: 8/255, blue: 6/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
            }
            .frame(height: 500)
            
            // Title overlay
            VStack(alignment: .leading, spacing: 16) {
                // Featured badge
                if event.isFeatured {
                    featuredBadge
                }
                
                // Title
                Text(event.name)
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
                
                // Date + location
                HStack(spacing: 16) {
                    Label(event.dateFormatted, systemImage: "calendar.badge.clock")
                    if let location = event.locationShort {
                        Label(location, systemImage: "location.fill")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 255/255, green: 127/255, blue: 110/255),
                            Color(red: 255/255, green: 191/255, blue: 105/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(height: 500)
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Stats cards
            statsSection
            
            // Description
            descriptionSection
            
            // Attendees
            if let attendees = event.attendees, attendees > 0 {
                attendeesSection
            }
            
            // Location
            if event.locationShort != nil {
                locationSection
            }
            
            // Spacer for floating button
            Spacer()
                .frame(height: 100)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            if let attendees = event.attendees {
                statCard(
                    icon: "person.2.fill",
                    title: "\(attendees)",
                    subtitle: "Going",
                    gradient: [
                        Color(red: 255/255, green: 127/255, blue: 110/255),
                        Color(red: 255/255, green: 191/255, blue: 105/255)
                    ]
                )
            }
            
            statCard(
                icon: "mappin.circle.fill",
                title: "SF",
                subtitle: "Location",
                gradient: [
                    Color(red: 180/255, green: 140/255, blue: 100/255),
                    Color(red: 255/255, green: 191/255, blue: 105/255)
                ]
            )
            
            statCard(
                icon: "clock.fill",
                title: "3h",
                subtitle: "Duration",
                gradient: [
                    Color(red: 140/255, green: 200/255, blue: 120/255),
                    Color(red: 180/255, green: 220/255, blue: 160/255)
                ]
            )
        }
    }
    
    private func statCard(icon: String, title: String, subtitle: String, gradient: [Color]) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Description
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(event.description ?? "Join us for an unforgettable evening of connection, music, and genuine moments. This is where magic happens.")
                .font(.system(size: 17))
                .foregroundColor(Color.white.opacity(0.8))
                .lineSpacing(8)
        }
    }
    
    // MARK: - Attendees
    
    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Who's going")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<min(8, event.attendees ?? 0), id: \.self) { i in
                        attendeeAvatar(index: i)
                    }
                    
                    if let attendees = event.attendees, attendees > 8 {
                        moreAttendeesCard(count: attendees - 8)
                    }
                }
            }
        }
    }
    
    private func attendeeAvatar(index: Int) -> some View {
        VStack(spacing: 8) {
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
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.3), radius: 8)
            
            Text("User")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func moreAttendeesCard(count: Int) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 60, height: 60)
                .overlay(
                    Text("+\(count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Text("more")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    // MARK: - Location
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Location")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 255/255, green: 127/255, blue: 110/255),
                                        Color(red: 255/255, green: 191/255, blue: 105/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        if let location = event.locationShort {
                            Text(location)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Button {
                            HapticManager.shared.impact(.light)
                        } label: {
                            Text("Get Directions")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 255/255, green: 127/255, blue: 110/255))
                        }
                    }
                )
        }
    }
    
    // MARK: - Floating Header
    
    private var floatingHeader: some View {
        VStack {
            HStack {
                Text(event.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                .ultraThinMaterial
            )
            .opacity(headerOpacity)
            
            Spacer()
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Floating RSVP Button
    
    private var floatingRSVPButton: some View {
        VStack {
            Spacer()
            
            Button {
                handleRSVP()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: isRSVPed ? "checkmark.circle.fill" : "calendar.badge.plus")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text(isRSVPed ? "You're going!" : "RSVP")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(isRSVPed ? Color(red: 10/255, green: 8/255, blue: 6/255) : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Capsule()
                        .fill(
                            isRSVPed
                                ? LinearGradient(
                                    colors: [
                                        Color(red: 140/255, green: 200/255, blue: 120/255),
                                        Color(red: 180/255, green: 220/255, blue: 160/255)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [
                                        Color(red: 255/255, green: 127/255, blue: 110/255),
                                        Color(red: 255/255, green: 191/255, blue: 105/255)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .shadow(color: Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.4), radius: 20, y: 8)
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Close Button
    
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    HapticManager.shared.impact(.light)
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .padding(.trailing, 24)
                .padding(.top, 54)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Components
    
    private var premiumPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.3),
                    Color(red: 10/255, green: 8/255, blue: 6/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "photo.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
        }
    }
    
    private var featuredBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.system(size: 14))
            Text("Featured")
                .font(.system(size: 15, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 255/255, green: 127/255, blue: 110/255),
                            Color(red: 255/255, green: 191/255, blue: 105/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.5), radius: 12)
        )
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingSuccess = false
                    }
                }
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 140/255, green: 200/255, blue: 120/255),
                                    Color(red: 180/255, green: 220/255, blue: 160/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(red: 140/255, green: 200/255, blue: 120/255).opacity(0.5), radius: 20)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text("You're going!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("We'll send you event details")
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .padding(40)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Actions
    
    private func handleRSVP() {
        HapticManager.shared.impact(.heavy)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isRSVPed.toggle()
        }
        
        if isRSVPed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showingSuccess = true
                }
                
                HapticManager.shared.success()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingSuccess = false
                    }
                }
            }
        }
    }
}

// MARK: - Scroll Offset Key

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    @Previewable @Namespace var namespace
    PremiumEventDetailView(
        event: DiscoverEvent(
            id: "1",
            name: "Venn Club Dinner",
            dateFormatted: "Friday, Feb 28 at 7:00 PM",
            locationShort: "The Barrel Room",
            imageUrl: nil,
            attendees: 24,
            isFeatured: true
        ),
        namespace: namespace
    )
}
