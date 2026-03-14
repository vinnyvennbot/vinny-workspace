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

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Premium Event Detail View

/// Full-screen premium event detail with parallax hero, glass stats, floating RSVP
struct PremiumEventDetailView: View {
    let event: DiscoverEvent
    var namespace: Namespace.ID

    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var isRSVPed = false
    @State private var showingSuccess = false
    @GestureState private var gestureOffset: CGFloat = 0

    // Parallax + opacity helpers
    private var headerOpacity: Double { min(max(scrollOffset / 180, 0), 1) }
    private var imageScale: CGFloat   { max(1 + (scrollOffset > 0 ? scrollOffset / 900 : 0), 1) }
    private var imageOffset: CGFloat  { scrollOffset > 0 ? -scrollOffset * 0.45 : 0 }

    var body: some View {
        ZStack {
            darkBg.ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero section
                        heroSection(geometry: geometry)

                        // Content
                        contentSection
                            .background(darkBg)
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: proxy.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
            }

            // Floating title bar on scroll
            floatingHeader

            // Floating RSVP button
            floatingRSVPButton

            // Close button
            closeButton

            // RSVP success overlay
            if showingSuccess {
                successOverlay
            }
        }
        .gesture(
            DragGesture()
                .updating($gestureOffset) { value, state, _ in
                    if value.translation.height > 0 { state = value.translation.height }
                }
                .onEnded { value in
                    if value.translation.height > 180 {
                        HapticManager.shared.impact(.medium)
                        dismiss()
                    }
                }
        )
        .offset(y: gestureOffset * 0.6)
    }

    // MARK: - Hero Section

    private func heroSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            Group {
                if let urlString = event.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            heroPlaceholder
                        }
                    }
                } else {
                    heroPlaceholder
                }
            }
            .frame(width: geometry.size.width, height: 500)
            .scaleEffect(imageScale)
            .offset(y: imageOffset)
            .clipped()

            // Gradient fade to dark
            VStack(spacing: 0) {
                LinearGradient(colors: [darkBg.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 140)
                Spacer()
                LinearGradient(colors: [.clear, darkBg.opacity(0.65), darkBg], startPoint: .top, endPoint: .bottom)
                    .frame(height: 220)
            }
            .frame(height: 500)

            // Hero title block
            VStack(alignment: .leading, spacing: 14) {
                if event.isFeatured { featuredBadge }

                Text(event.name)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 12, y: 4)

                HStack(spacing: 16) {
                    Label(event.dateFormatted, systemImage: "calendar.badge.clock")
                    if let location = event.locationShort {
                        Label(location, systemImage: "location.fill")
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: [coral, warmGold], startPoint: .leading, endPoint: .trailing)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(height: 500)
    }

    private var heroPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [coral.opacity(0.28), Color(red: 60/255, green: 25/255, blue: 35/255), darkBg],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "photo.fill")
                .font(.system(size: 56))
                .foregroundColor(warmWhite.opacity(0.12))
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            statsSection

            descriptionSection

            if let attendees = event.attendees, attendees > 0 {
                attendeesSection
            }

            if event.locationShort != nil {
                locationSection
            }

            // Space for floating RSVP button
            Spacer().frame(height: 100)
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: 12) {
            if let attendees = event.attendees {
                statCard(
                    icon: "person.2.fill",
                    title: "\(attendees)",
                    subtitle: "Going",
                    gradient: [coral, warmGold]
                )
            }

            statCard(
                icon: "mappin.circle.fill",
                title: "SF",
                subtitle: "Location",
                gradient: [warmGold.opacity(0.8), warmGold]
            )

            statCard(
                icon: "clock.fill",
                title: "3h",
                subtitle: "Duration",
                gradient: [Color(red: 100/255, green: 200/255, blue: 130/255), Color(red: 140/255, green: 220/255, blue: 160/255)]
            )
        }
    }

    private func statCard(icon: String, title: String, subtitle: String, gradient: [Color]) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: gradient.map { $0.opacity(0.18) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            }

            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(warmWhite)
                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(mutedText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(subtleBorder, lineWidth: 1)
                )
        )
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("About")
            Text(event.description ?? "Join us for an unforgettable evening of connection, music, and genuine moments. This is where magic happens.")
                .font(.system(size: 17))
                .foregroundColor(mutedText)
                .lineSpacing(7)
        }
    }

    // MARK: - Attendees

    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Who's going")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
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
        VStack(spacing: 7) {
            Circle()
                .fill(LinearGradient(colors: [coral, warmGold], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 56, height: 56)
                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 2))
                .shadow(color: coral.opacity(0.25), radius: 7)
            Text("Guest")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(mutedText)
        }
    }

    private func moreAttendeesCard(count: Int) -> some View {
        VStack(spacing: 7) {
            Circle()
                .fill(elevatedBg)
                .frame(width: 56, height: 56)
                .overlay(
                    Text("+\(count)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(warmWhite)
                )
                .overlay(Circle().stroke(subtleBorder, lineWidth: 1))
            Text("more")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(mutedText)
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Location")

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBg)
                .frame(height: 180)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(subtleBorder, lineWidth: 1)
                )
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(LinearGradient(colors: [coral, warmGold], startPoint: .topLeading, endPoint: .bottomTrailing))

                        if let location = event.locationShort {
                            Text(location)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(warmWhite)
                        }

                        Button {
                            HapticManager.shared.impact(.light)
                        } label: {
                            Text("Get Directions")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(coral)
                        }
                    }
                )
        }
    }

    // MARK: - Section Heading

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundColor(warmWhite)
    }

    // MARK: - Floating Header

    private var floatingHeader: some View {
        VStack {
            HStack {
                Text(event.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(warmWhite)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .opacity(headerOpacity)

            Spacer()
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Floating RSVP

    private var floatingRSVPButton: some View {
        VStack {
            Spacer()
            Button { handleRSVP() } label: {
                HStack(spacing: 12) {
                    Image(systemName: isRSVPed ? "checkmark.circle.fill" : "calendar.badge.plus")
                        .font(.system(size: 20, weight: .bold))
                    Text(isRSVPed ? "You're going!" : "RSVP")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(isRSVPed ? darkBg : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Capsule()
                        .fill(
                            isRSVPed
                                ? LinearGradient(colors: [Color(red: 100/255, green: 200/255, blue: 130/255), Color(red: 140/255, green: 220/255, blue: 160/255)], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [coral, warmGold], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: isRSVPed ? Color(red: 100/255, green: 200/255, blue: 130/255).opacity(0.35) : coral.opacity(0.4), radius: 18, y: 7)
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
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(warmWhite)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                        )
                }
                .padding(.trailing, 24)
                .padding(.top, 54)
            }
            Spacer()
        }
    }

    // MARK: - Featured Badge

    private var featuredBadge: some View {
        HStack(spacing: 7) {
            Image(systemName: "star.fill").font(.system(size: 13))
            Text("Featured").font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(LinearGradient(colors: [coral, warmGold], startPoint: .leading, endPoint: .trailing))
                .shadow(color: coral.opacity(0.45), radius: 12)
        )
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingSuccess = false
                    }
                }

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 100/255, green: 200/255, blue: 130/255), Color(red: 140/255, green: 220/255, blue: 165/255)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 96, height: 96)
                        .shadow(color: Color(red: 100/255, green: 200/255, blue: 130/255).opacity(0.45), radius: 22)

                    Image(systemName: "checkmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 10) {
                    Text("You're going!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(warmWhite)
                    Text("We'll send you event details")
                        .font(.system(size: 16))
                        .foregroundColor(mutedText)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(subtleBorder, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 44)
            .transition(.scale(scale: 0.88).combined(with: .opacity))
        }
    }

    // MARK: - RSVP Action

    private func handleRSVP() {
        HapticManager.shared.impact(.heavy)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
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
