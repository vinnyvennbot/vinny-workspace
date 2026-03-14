import SwiftUI

// MARK: - Event Detail View

struct EventDetailView: View {
    let event: DiscoverEvent
    @Environment(\.dismiss) private var dismiss
    @State private var isRSVPed = false
    @State private var showingRSVPSuccess = false

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection

                    VStack(alignment: .leading, spacing: VennSpacing.xxl) {
                        headerSection
                        statsBar
                        rsvpButton

                        if let description = event.description {
                            descriptionSection(description)
                        }

                        if let attendees = event.attendees, attendees > 0 {
                            attendeesSection
                        }

                        if event.locationShort != nil {
                            locationSection
                        }
                    }
                    .padding(.horizontal, VennSpacing.xl)
                    .padding(.top, VennSpacing.xxl)
                    .padding(.bottom, VennSpacing.massive)
                }
            }
            .ignoresSafeArea(edges: .top)

            if showingRSVPSuccess {
                rsvpSuccessOverlay
            }
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(VennColors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .padding(.leading, VennSpacing.xl)
            .padding(.top, 54)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
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

            // Bottom gradient fade into dark background
            LinearGradient(
                colors: [.clear, VennColors.darkBg.opacity(0.5), VennColors.darkBg],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .frame(height: 360)
        .clipped()
    }

    private var heroPlaceholder: some View {
        LinearGradient(
            colors: [VennColors.coral.opacity(0.3), VennColors.darkBg],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: VennSpacing.sm) {
            if event.isFeatured {
                Text("Featured")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(VennColors.coral)
                            .shadow(color: VennColors.coral.opacity(0.35), radius: 8, y: 2)
                    )
            }

            Text(event.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(VennColors.textPrimary)

            Label(event.dateFormatted, systemImage: "calendar")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(VennColors.coral)

            if let location = event.locationShort {
                Label(location, systemImage: "mappin")
                    .font(VennTypography.body)
                    .foregroundColor(VennColors.textSecondary)
            }
        }
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: VennSpacing.xl) {
            if let attendees = event.attendees {
                statItem(icon: "person.2.fill", value: "\(attendees)", label: "Going", color: VennColors.coral)
            }
            if event.locationShort != nil {
                statItem(icon: "mappin.circle.fill", value: "In-person", label: "Event", color: VennColors.textSecondary)
            }
            Spacer()
        }
    }

    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: VennSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)
                Text(label)
                    .font(VennTypography.caption)
                    .foregroundColor(VennColors.textTertiary)
            }
        }
    }

    // MARK: - RSVP Button

    private var rsvpButton: some View {
        Button {
            withAnimation(VennAnimation.standard) {
                isRSVPed.toggle()
                if isRSVPed {
                    showingRSVPSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        withAnimation(VennAnimation.gentle) {
                            showingRSVPSuccess = false
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: VennSpacing.sm) {
                Image(systemName: isRSVPed ? "checkmark.circle.fill" : "calendar.badge.plus")
                    .font(.system(size: 17, weight: .bold))
                Text(isRSVPed ? "You're going!" : "RSVP")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(isRSVPed ? VennColors.darkBg : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Capsule()
                    .fill(
                        isRSVPed
                            ? AnyShapeStyle(LinearGradient(
                                colors: [VennColors.success, VennColors.success.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                              ))
                            : AnyShapeStyle(VennGradients.primary)
                    )
                    .shadow(
                        color: isRSVPed ? VennColors.success.opacity(0.3) : VennColors.coral.opacity(0.35),
                        radius: 14,
                        y: 5
                    )
            )
        }
        .animation(VennAnimation.snappy, value: isRSVPed)
    }

    // MARK: - Description

    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: VennSpacing.md) {
            sectionHeading("About")
            Text(text)
                .font(VennTypography.body)
                .foregroundColor(VennColors.textSecondary)
                .lineSpacing(5)
        }
    }

    // MARK: - Attendees

    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: VennSpacing.md) {
            sectionHeading("Who's going")

            HStack(spacing: -10) {
                ForEach(0..<min(5, event.attendees ?? 0), id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [VennColors.coral, VennColors.gold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                        .overlay(Circle().stroke(VennColors.darkBg, lineWidth: 2))
                        .shadow(color: VennColors.coral.opacity(0.2), radius: 4)
                        .zIndex(Double(5 - index))
                }

                if let count = event.attendees, count > 5 {
                    Circle()
                        .fill(VennColors.surfaceSecondary)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Text("+\(count - 5)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(VennColors.textSecondary)
                        )
                        .overlay(Circle().stroke(VennColors.darkBg, lineWidth: 2))
                }
            }
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: VennSpacing.md) {
            sectionHeading("Location")

            if let location = event.locationShort {
                HStack(spacing: VennSpacing.md) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(VennColors.coral)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(location)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(VennColors.textPrimary)
                        Text("San Francisco, CA")
                            .font(VennTypography.caption)
                            .foregroundColor(VennColors.textTertiary)
                    }

                    Spacer()
                }
                .padding(VennSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                        .fill(VennColors.surfacePrimary)
                )
            }
        }
    }

    // MARK: - Section Heading

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .foregroundColor(VennColors.textPrimary)
    }

    // MARK: - RSVP Success Overlay

    private var rsvpSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(VennAnimation.gentle) { showingRSVPSuccess = false }
                }

            VStack(spacing: VennSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [VennColors.success, VennColors.success.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: VennColors.success.opacity(0.4), radius: 20)

                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(spacing: VennSpacing.sm) {
                    Text("You're going!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(VennColors.textPrimary)
                    Text("We'll send you event details soon")
                        .font(VennTypography.body)
                        .foregroundColor(VennColors.textSecondary)
                }
            }
            .padding(VennSpacing.xxxl)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.xxl, style: .continuous)
                    .fill(VennColors.surfacePrimary)
            )
            .padding(.horizontal, 44)
            .transition(.scale(scale: 0.88).combined(with: .opacity))
        }
    }
}

// MARK: - DiscoverEvent Extension

extension DiscoverEvent {
    var description: String? {
        "Join us for an unforgettable evening of connection, music, and genuine moments. This is where magic happens."
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
