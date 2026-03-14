import SwiftUI

/// PREMIUM Event Card - Stunning UI/UX
/// Features: Parallax, glass-morphism, haptics, advanced animations, premium shadows
struct PremiumEventCardView: View {
    let event: DiscoverEvent
    let index: Int
    
    @State private var isPressed = false
    @State private var dragOffset: CGFloat = 0
    @State private var showingDetail = false
    @GestureState private var gestureOffset: CGFloat = 0
    @Namespace private var namespace
    
    // Parallax effect
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with parallax
                backgroundLayer(geometry: geometry)
                
                // Glass overlay with blur
                glassOverlay
                
                // Content with premium shadows
                contentLayer
                
                // Gradient shimmer effect
                if event.isFeatured {
                    shimmerGradient
                }
            }
            .frame(width: 360, height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(borderGradient, lineWidth: 2)
            )
            .scaleEffect(pressScale)
            .rotationEffect(.degrees(rotationAngle))
            .offset(x: totalOffset)
            .gesture(swipeGesture)
            .onTapGesture {
                handleTap()
            }
            .sheet(isPresented: $showingDetail) {
                PremiumEventDetailView(event: event, namespace: namespace)
            }
            .onAppear {
                // Staggered entrance animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                    scrollOffset = 0
                }
            }
        }
        .frame(width: 360, height: 280)
    }
    
    // MARK: - Background Layer with Parallax
    
    private func backgroundLayer(geometry: GeometryProxy) -> some View {
        Group {
            if let imageUrl = event.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 360, height: 280)
                            // Parallax effect on scroll
                            .offset(x: scrollOffset * 0.3)
                            .scaleEffect(isPressed ? 1.1 : 1.0)
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
        .overlay(
            // Dynamic gradient overlay that responds to press
            LinearGradient(
                colors: gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(gradientOpacity)
        )
    }
    
    private var premiumPlaceholder: some View {
        ZStack {
            // Animated mesh gradient background
            MeshGradient(
                colors: [
                    Color(red: 255/255, green: 127/255, blue: 110/255),
                    Color(red: 255/255, green: 191/255, blue: 105/255),
                    Color(red: 120/255, green: 40/255, blue: 50/255),
                    Color(red: 10/255, green: 8/255, blue: 6/255)
                ]
            )
            
            // Floating particles effect
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 100, height: 100)
                .blur(radius: 20)
                .offset(x: -60, y: -40)
            
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 140, height: 140)
                .blur(radius: 30)
                .offset(x: 80, y: 60)
            
            // Coming soon with glow
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.2))
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)
                    
                    Text("?")
                        .font(.system(size: 56, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 255/255, green: 191/255, blue: 105/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text("COMING SOON")
                    .font(.system(size: 11, weight: .black))
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    // MARK: - Glass Overlay
    
    private var glassOverlay: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .opacity(isPressed ? 0.3 : 0.1)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
    }
    
    // MARK: - Content Layer
    
    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top bar with premium badge
            HStack {
                premiumBadge
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Bottom content with glass background
            VStack(alignment: .leading, spacing: 10) {
                // Date + location with icons
                HStack(spacing: 14) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 13, weight: .semibold))
                        Text(event.dateFormatted)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                    if let location = event.locationShort {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 13, weight: .semibold))
                            Text(location)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.9), Color(red: 255/255, green: 191/255, blue: 105/255)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
                // Event title with shadow
                Text(event.name)
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 2)
                
                // Social proof with glow
                if let attendees = event.attendees, attendees > 0 {
                    HStack(spacing: 8) {
                        // Attendee avatars with overlap
                        HStack(spacing: -8) {
                            ForEach(0..<min(3, attendees), id: \.self) { i in
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
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                    .shadow(color: Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.5), radius: 4)
                            }
                        }
                        
                        Text("\(attendees) going")
                            .font(.system(size: 15, weight: .bold))
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
                }
            }
            .padding(20)
            .background(
                // Glass-morphism background
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
        }
    }
    
    // MARK: - Premium Badge
    
    private var premiumBadge: some View {
        Group {
            if event.isFeatured {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text("Featured")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
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
                        .shadow(color: Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.6), radius: 12, x: 0, y: 4)
                )
            } else {
                Text("Available")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                    )
            }
        }
    }
    
    // MARK: - Shimmer Effect
    
    private var shimmerGradient: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0),
                Color.white.opacity(0.3),
                Color.white.opacity(0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .rotationEffect(.degrees(45))
        .offset(x: scrollOffset * 0.5)
        .blendMode(.overlay)
    }
    
    // MARK: - Computed Properties
    
    private var pressScale: CGFloat {
        isPressed ? 0.96 : 1.0
    }
    
    private var rotationAngle: Double {
        Double(totalOffset) * 0.02
    }
    
    private var totalOffset: CGFloat {
        dragOffset + gestureOffset
    }
    
    private var shadowColor: Color {
        event.isFeatured
            ? Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.4)
            : Color.black.opacity(0.3)
    }
    
    private var shadowRadius: CGFloat {
        isPressed ? 8 : 20
    }
    
    private var shadowY: CGFloat {
        isPressed ? 4 : 12
    }
    
    private var borderGradient: LinearGradient {
        if event.isFeatured {
            return LinearGradient(
                colors: [
                    Color(red: 255/255, green: 127/255, blue: 110/255).opacity(0.6),
                    Color(red: 255/255, green: 191/255, blue: 105/255).opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var gradientColors: [Color] {
        if isPressed {
            return [
                Color.clear,
                Color.black.opacity(0.4),
                Color.black.opacity(0.8)
            ]
        } else {
            return [
                Color.clear,
                Color.black.opacity(0.2),
                Color.black.opacity(0.7)
            ]
        }
    }
    
    private var gradientOpacity: Double {
        isPressed ? 1.0 : 0.9
    }
    
    // MARK: - Gestures
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .updating($gestureOffset) { value, state, _ in
                state = value.translation.width
            }
            .onChanged { value in
                // Haptic feedback on drag start
                if abs(value.translation.width) > 10 && abs(dragOffset) < 1 {
                    HapticManager.shared.impact(.light)
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    // Swipe to dismiss logic (can add later)
                    if abs(value.translation.width) > 100 {
                        HapticManager.shared.impact(.medium)
                    }
                    dragOffset = 0
                }
            }
    }
    
    private func handleTap() {
        // Premium haptic feedback
        HapticManager.shared.impact(.medium)
        
        // Micro-animation on tap
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
            showingDetail = true
        }
    }
}

// MARK: - Mesh Gradient Helper

struct MeshGradient: View {
    let colors: [Color]
    
    var body: some View {
        ZStack {
            ForEach(0..<colors.count, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [colors[index], colors[index].opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: offsetX(for: index), y: offsetY(for: index))
                    .blur(radius: 40)
            }
        }
    }
    
    private func offsetX(for index: Int) -> CGFloat {
        switch index {
        case 0: return -100
        case 1: return 100
        case 2: return -80
        default: return 80
        }
    }
    
    private func offsetY(for index: Int) -> CGFloat {
        switch index {
        case 0: return -80
        case 1: return -60
        case 2: return 100
        default: return 120
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 20) {
            PremiumEventCardView(
                event: DiscoverEvent(
                    id: "1",
                    name: "Venn Club Dinner",
                    dateFormatted: "Feb 28",
                    locationShort: "SF",
                    imageUrl: nil,
                    attendees: 24,
                    isFeatured: true
                ),
                index: 0
            )
        }
        .padding(20)
    }
    .background(Color(red: 10/255, green: 8/255, blue: 6/255))
}
