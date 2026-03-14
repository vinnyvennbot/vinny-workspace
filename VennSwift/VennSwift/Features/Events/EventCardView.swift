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

    // AI-personalization fields (optional for backward compatibility)
    var matchReason: String?   // "You both love intimate dining and live jazz"
    var iceBreaker: String?    // "Ask them about the best hidden speakeasy in SF"
    var isFriendPlan: Bool     // true = friend invite, false = AI recommendation
    var hostName: String?      // Display name of the plan host
    var capacity: Int?         // Total capacity slots for the plan

    // Convenience initializer preserving the original call-site signature
    init(
        id: String,
        name: String,
        dateFormatted: String,
        locationShort: String? = nil,
        imageUrl: String? = nil,
        attendees: Int? = nil,
        isFeatured: Bool,
        matchReason: String? = nil,
        iceBreaker: String? = nil,
        isFriendPlan: Bool = false,
        hostName: String? = nil,
        capacity: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.dateFormatted = dateFormatted
        self.locationShort = locationShort
        self.imageUrl = imageUrl
        self.attendees = attendees
        self.isFeatured = isFeatured
        self.matchReason = matchReason
        self.iceBreaker = iceBreaker
        self.isFriendPlan = isFriendPlan
        self.hostName = hostName
        self.capacity = capacity
    }
}

// MARK: - Event Card View

struct EventCardView: View {
    let event: DiscoverEvent
    @State private var isPressed = false
    @State private var showingDetail = false
    @State private var gradientShift = false
    @State private var isSaved: Bool = false
    @State private var showSavedConfirmation = false

    private var savedKey: String { "saved_event_\(event.id)" }

    var body: some View {
        ZStack {
            backgroundLayer

            // Top inner shadow for depth
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.28),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 48)
                Spacer()
            }

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
                .padding(.horizontal, VennSpacing.md)
                .padding(.top, VennSpacing.md)

                Spacer()

                // Bottom info block
                VStack(alignment: .leading, spacing: VennSpacing.xs) {
                    Text(event.name)
                        .font(VennTypography.bodyLarge)
                        .fontWeight(.bold)
                        .foregroundColor(VennColors.textPrimary)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.6), radius: 4, y: 2)

                    HStack(spacing: VennSpacing.sm + 2) {
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

                    if let attendees = event.attendees, attendees > 0 {
                        HStack(spacing: VennSpacing.xs) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))
                            Text("\(attendees) going")
                                .font(VennTypography.captionBold)
                        }
                        .foregroundColor(VennColors.coral)
                    }
                }
                .padding(.horizontal, VennSpacing.md + 2)
                .padding(.bottom, VennSpacing.md + 2)
            }
        }
        .frame(width: 300, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous))
        .shadow(
            color: Color.black.opacity(isPressed ? 0.18 : 0.40),
            radius: isPressed ? 6 : 16,
            x: 0,
            y: isPressed ? 2 : 6
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(VennAnimation.snappy, value: isPressed)
        .onTapGesture {
            Task { @MainActor in
                HapticManager.shared.impact(.light)
            }
            showingDetail = true
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .contextMenu {
            ShareLink(item: "Check out \(event.name) on Venn!") {
                Label("Share Event", systemImage: "square.and.arrow.up")
            }

            Button {
                HapticManager.shared.impact(.light)
                isSaved.toggle()
                UserDefaults.standard.set(isSaved, forKey: savedKey)
                if isSaved {
                    withAnimation(VennAnimation.snappy) { showSavedConfirmation = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation(VennAnimation.gentle) { showSavedConfirmation = false }
                    }
                }
            } label: {
                Label(isSaved ? "Unsave Event" : "Save Event",
                      systemImage: isSaved ? "bookmark.fill" : "bookmark")
            }
        }
        .overlay(alignment: .top) {
            if showSavedConfirmation {
                HStack(spacing: VennSpacing.xs) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Saved")
                        .font(VennTypography.captionBold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, VennSpacing.md)
                .padding(.vertical, VennSpacing.xs + 1)
                .background(
                    Capsule()
                        .fill(VennColors.coral)
                        .shadow(color: VennColors.coral.opacity(0.4), radius: 8, y: 3)
                )
                .transition(.scale(scale: 0.85).combined(with: .opacity))
                .padding(.top, VennSpacing.sm)
            }
        }
        .animation(VennAnimation.snappy, value: showSavedConfirmation)
        .onAppear {
            isSaved = UserDefaults.standard.bool(forKey: savedKey)
        }
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

    /// Animated gradient background used when no image is available.
    /// Subtly shifts coral opacity to give the card life without being distracting.
    private var noImageBackground: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    VennColors.coral.opacity(gradientShift ? 0.48 : 0.32),
                    VennColors.surfaceTertiary,
                    VennColors.darkBg
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(
                .easeInOut(duration: 3).repeatForever(autoreverses: true),
                value: gradientShift
            )
            .onAppear {
                gradientShift = true
            }

            // Large ghosted name in background for visual richness
            Text(event.name)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundColor(VennColors.textPrimary.opacity(0.06))
                .lineLimit(2)
                .padding(.horizontal, VennSpacing.md + 2)
                .padding(.bottom, VennSpacing.sm + 2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Featured Badge

    private var featuredBadge: some View {
        Text("Featured")
            .font(VennTypography.captionBold)
            .foregroundColor(.white)
            .padding(.horizontal, VennSpacing.sm + 2)
            .padding(.vertical, VennSpacing.xs + 1)
            .background(
                Capsule()
                    .fill(VennColors.coral)
                    // Coral glow — the distinctive badge shimmer
                    .shadow(color: VennColors.coral.opacity(0.55), radius: 8, y: 0)
                    .shadow(color: VennColors.coral.opacity(0.30), radius: 16, y: 4)
            )
    }
}

// MARK: - AI Insight Row (matchReason + iceBreaker pill)

/// Rendered beneath an EventCardView in the "For You" feed section to surface
/// the AI-generated match reason and ice-breaker without cluttering the card itself.
struct AIInsightRow: View {
    let matchReason: String?
    let iceBreaker: String?

    @State private var iceBreakerCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: VennSpacing.xs) {
            if let reason = matchReason {
                HStack(alignment: .top, spacing: VennSpacing.xs) {
                    Text("Matched because:")
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textSecondary)
                    Text(reason)
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textPrimary)
                        .lineLimit(2)
                }
            }

            if let breaker = iceBreaker {
                Button {
                    UIPasteboard.general.string = breaker
                    Task { @MainActor in
                        HapticManager.shared.impact(.light)
                    }
                    withAnimation(VennAnimation.snappy) { iceBreakerCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(VennAnimation.gentle) { iceBreakerCopied = false }
                    }
                } label: {
                    HStack(spacing: VennSpacing.xs) {
                        Image(systemName: iceBreakerCopied ? "checkmark" : "bubble.left")
                            .font(.system(size: 10, weight: .semibold))
                        Text(iceBreakerCopied ? "Copied!" : breaker)
                            .font(VennTypography.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(VennColors.indigo)
                    .padding(.horizontal, VennSpacing.sm + 2)
                    .padding(.vertical, VennSpacing.xs + 1)
                    .background(
                        Capsule()
                            .fill(VennColors.indigo.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .animation(VennAnimation.snappy, value: iceBreakerCopied)
            }
        }
        .frame(width: 300, alignment: .leading)
    }
}

// MARK: - EventCardWithInsights
// Composites EventCardView + AIInsightRow. Used only in the AI-powered sections
// of DiscoveryFeedView so that EventCardView remains universally reusable.

struct EventCardWithInsights: View {
    let event: DiscoverEvent

    var body: some View {
        VStack(alignment: .leading, spacing: VennSpacing.sm) {
            EventCardView(event: event)

            if event.matchReason != nil || event.iceBreaker != nil {
                AIInsightRow(matchReason: event.matchReason, iceBreaker: event.iceBreaker)
                    .padding(.horizontal, 2)
            }
        }
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
