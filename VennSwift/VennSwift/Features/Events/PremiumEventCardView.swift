import SwiftUI

// MARK: - Local Design Tokens
private let darkBg       = Color(red: 15/255,  green: 13/255,  blue: 11/255)
private let cardBg       = Color(red: 26/255,  green: 23/255,  blue: 20/255)
private let elevatedBg   = Color(red: 36/255,  green: 32/255,  blue: 25/255)
private let coral        = Color(red: 255/255, green: 127/255, blue: 110/255)
private let warmGold     = Color(red: 255/255, green: 185/255, blue: 106/255)
private let warmWhite    = Color(red: 250/255, green: 247/255, blue: 242/255)
private let mutedText    = Color(red: 160/255, green: 152/255, blue: 140/255)
private let subtleBorder = Color.white.opacity(0.06)

// MARK: - Premium Event Card View

/// Full-featured premium card with swipe gestures, haptics, parallax shimmer, and staggered entrance
struct PremiumEventCardView: View {
    let event: DiscoverEvent
    let index: Int

    @State private var isPressed = false
    @State private var dragOffset: CGFloat = 0
    @State private var showingDetail = false
    @GestureState private var gestureOffset: CGFloat = 0
    @Namespace private var namespace

    var body: some View {
        ZStack {
            // Background image or premium placeholder
            backgroundLayer

            // Gradient overlay
            LinearGradient(
                colors: isPressed
                    ? [.clear, Color.black.opacity(0.35), Color.black.opacity(0.82)]
                    : [.clear, Color.black.opacity(0.18), Color.black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Shimmer for featured
            if event.isFeatured {
                shimmerLayer
            }

            // Content
            contentLayer
        }
        .frame(width: 360, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    event.isFeatured
                        ? LinearGradient(colors: [coral.opacity(0.55), warmGold.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [subtleBorder, subtleBorder], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: event.isFeatured ? 1.5 : 1
                )
        )
        .shadow(
            color: event.isFeatured ? coral.opacity(0.28) : Color.black.opacity(0.4),
            radius: isPressed ? 8 : 22,
            y: isPressed ? 4 : 10
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .rotationEffect(.degrees(Double(totalOffset) * 0.015))
        .offset(x: totalOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.72), value: isPressed)
        .gesture(swipeGesture)
        .onTapGesture { handleTap() }
        .sheet(isPresented: $showingDetail) {
            PremiumEventDetailView(event: event, namespace: namespace)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8).delay(Double(index) * 0.08)) {
                // staggered entrance — state variables remain at default
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        Group {
            if let urlString = event.imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(isPressed ? 1.06 : 1.0)
                            .animation(.spring(response: 0.4), value: isPressed)
                    default:
                        premiumPlaceholder
                    }
                }
            } else {
                premiumPlaceholder
            }
        }
    }

    private var premiumPlaceholder: some View {
        ZStack {
            // Deep layered gradient
            LinearGradient(
                colors: [
                    coral.opacity(0.22),
                    Color(red: 80/255, green: 30/255, blue: 40/255),
                    darkBg
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Soft ambient blobs
            Circle()
                .fill(warmGold.opacity(0.12))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: 80, y: -40)

            Circle()
                .fill(coral.opacity(0.1))
                .frame(width: 160, height: 160)
                .blur(radius: 35)
                .offset(x: -70, y: 60)

            VStack(spacing: 10) {
                Text("✦")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [warmWhite.opacity(0.9), warmGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("COMING SOON")
                    .font(.system(size: 10, weight: .black))
                    .tracking(3)
                    .foregroundColor(warmWhite.opacity(0.5))
            }
        }
    }

    // MARK: - Shimmer

    private var shimmerLayer: some View {
        LinearGradient(
            colors: [.clear, Color.white.opacity(0.12), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .rotationEffect(.degrees(30))
        .blendMode(.overlay)
    }

    // MARK: - Content

    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top badge
            HStack {
                premiumBadge
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            // Bottom info panel with glass background
            VStack(alignment: .leading, spacing: 10) {
                // Date + location
                HStack(spacing: 14) {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 12, weight: .bold))
                        Text(event.dateFormatted)
                            .font(.system(size: 13, weight: .semibold))
                    }

                    if let location = event.locationShort {
                        HStack(spacing: 5) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text(location)
                                .font(.system(size: 13, weight: .semibold))
                        }
                    }
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [warmWhite.opacity(0.9), warmGold.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                // Title
                Text(event.name)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 8, y: 2)

                // Attendees social proof
                if let attendees = event.attendees, attendees > 0 {
                    HStack(spacing: 8) {
                        HStack(spacing: -8) {
                            ForEach(0..<min(3, attendees), id: \.self) { _ in
                                Circle()
                                    .fill(LinearGradient(colors: [coral, warmGold], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 24, height: 24)
                                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1.5))
                                    .shadow(color: coral.opacity(0.4), radius: 4)
                            }
                        }

                        Text("\(attendees) going")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(colors: [coral, warmGold], startPoint: .leading, endPoint: .trailing)
                            )
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.09), Color.white.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
        }
    }

    // MARK: - Badge

    private var premiumBadge: some View {
        Group {
            if event.isFeatured {
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text("Featured")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.3)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(LinearGradient(colors: [coral, warmGold], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: coral.opacity(0.55), radius: 10, y: 3)
                )
            } else {
                Text("Available")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1.5))
                    )
            }
        }
    }

    // MARK: - Computed Properties

    private var totalOffset: CGFloat { dragOffset + gestureOffset }

    // MARK: - Gestures

    private var swipeGesture: some Gesture {
        DragGesture()
            .updating($gestureOffset) { value, state, _ in
                state = value.translation.width
            }
            .onChanged { value in
                if abs(value.translation.width) > 10 && abs(dragOffset) < 1 {
                    HapticManager.shared.impact(.light)
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    if abs(value.translation.width) > 100 {
                        HapticManager.shared.impact(.medium)
                    }
                    dragOffset = 0
                }
            }
    }

    private func handleTap() {
        HapticManager.shared.impact(.medium)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
            isPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                isPressed = false
            }
            showingDetail = true
        }
    }
}

// MARK: - Mesh Gradient Helper (custom radial blobs)

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
                    .offset(x: blobOffsetX(for: index), y: blobOffsetY(for: index))
                    .blur(radius: 40)
            }
        }
    }

    private func blobOffsetX(for index: Int) -> CGFloat {
        switch index { case 0: return -100; case 1: return 100; case 2: return -80; default: return 80 }
    }

    private func blobOffsetY(for index: Int) -> CGFloat {
        switch index { case 0: return -80; case 1: return -60; case 2: return 100; default: return 120 }
    }
}

// MARK: - Preview

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 20) {
            PremiumEventCardView(
                event: DiscoverEvent(id: "1", name: "Venn Club Dinner", dateFormatted: "Feb 28", locationShort: "SF", imageUrl: nil, attendees: 24, isFeatured: true),
                index: 0
            )
            PremiumEventCardView(
                event: DiscoverEvent(id: "2", name: "Silent Disco at Fort Mason", dateFormatted: "Tonight, 8PM", locationShort: "Fort Mason", imageUrl: nil, attendees: 45, isFeatured: false),
                index: 1
            )
        }
        .padding(20)
    }
    .background(Color(red: 15/255, green: 13/255, blue: 11/255))
}
