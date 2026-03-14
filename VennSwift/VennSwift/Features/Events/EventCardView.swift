import SwiftUI

// MARK: - DiscoverEvent Model

struct DiscoverEvent: Identifiable {
    let id: String
    let name: String
    let dateFormatted: String
    let locationShort: String?
    let imageUrl: String?
    let attendees: Int?
    let isFeatured: Bool
}

// MARK: - Event Card View

struct EventCardView: View {
    let event: DiscoverEvent
    @State private var isPressed = false
    @State private var showingDetail = false

    var body: some View {
        ZStack {
            backgroundLayer

            // Dark gradient for text legibility
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.68)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 0) {
                // Featured badge — top-left, only when featured
                HStack {
                    if event.isFeatured {
                        featuredBadge
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

                Spacer()

                // Bottom info block
                VStack(alignment: .leading, spacing: 5) {
                    Text(event.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(VennColors.textPrimary)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.6), radius: 4, y: 2)

                    HStack(spacing: 10) {
                        Label(event.dateFormatted, systemImage: "calendar")
                            .font(VennTypography.captionBold)
                            .foregroundColor(VennColors.textPrimary.opacity(0.78))

                        if let location = event.locationShort {
                            Label(location, systemImage: "mappin")
                                .font(VennTypography.captionBold)
                                .foregroundColor(VennColors.textPrimary.opacity(0.78))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .frame(width: 300, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous))
        .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 6)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(VennAnimation.snappy, value: isPressed)
        .onTapGesture { showingDetail = true }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .sheet(isPresented: $showingDetail) {
            EventDetailView(event: event)
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
                            .scaleEffect(isPressed ? 1.04 : 1.0)
                            .animation(VennAnimation.gentle, value: isPressed)
                    default:
                        noImageBackground
                    }
                }
            } else {
                noImageBackground
            }
        }
    }

    /// Rich gradient background used when no image is available.
    /// Diagonal coral fade over dark surface — NO placeholder text.
    private var noImageBackground: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    VennColors.coral.opacity(0.40),
                    VennColors.surfaceTertiary,
                    VennColors.darkBg
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Large ghosted name in background for visual richness
            Text(event.name)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundColor(VennColors.textPrimary.opacity(0.06))
                .lineLimit(2)
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Featured Badge

    private var featuredBadge: some View {
        Text("Featured")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(VennColors.coral)
                    .shadow(color: VennColors.coral.opacity(0.4), radius: 6, y: 2)
            )
    }
}

// MARK: - Preview

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 14) {
            EventCardView(event: DiscoverEvent(
                id: "1",
                name: "Venn Club Dinner",
                dateFormatted: "Feb 28",
                locationShort: "The Barrel Room",
                imageUrl: nil,
                attendees: 17,
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
            EventCardView(event: DiscoverEvent(
                id: "3",
                name: "Silent Disco at Fort Mason",
                dateFormatted: "Tonight, 8PM",
                locationShort: "Fort Mason",
                imageUrl: nil,
                attendees: 45,
                isFeatured: false
            ))
        }
        .padding(.horizontal, VennSpacing.xl)
    }
    .frame(height: 240)
    .background(VennColors.darkBg)
}
