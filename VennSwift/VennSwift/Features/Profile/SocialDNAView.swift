import SwiftUI

// MARK: - Social DNA
// A shareable personality card built from the user's event preferences, behavioral
// traits, and onboarding data. One-screen, screenshot-first design. Think Myers-Briggs
// meets nightlife. Bold graphic, instantly legible at thumbnail size on TikTok/IG.

// MARK: - Data Model

struct SocialDNAProfile {
    let userName: String
    let archetypeTitle: String       // e.g. "The Magnetic Connector"
    let archetypeSubtitle: String    // e.g. "Rare — only 6% of Venn users"
    let archetypeEmoji: String
    let energyType: EnergyType
    let timeType: TimeType
    let sceneType: SceneType
    let connectionType: ConnectionType
    let traits: [DNATrait]
    let compatibleWith: String       // e.g. "The Curator"
    let oppositeOf: String           // e.g. "The Homebody"
    let weekendMood: String          // one-liner
    let primaryColor: Color
    let secondaryColor: Color
}

enum EnergyType: String {
    case magnetic = "Magnetic"
    case mellow   = "Mellow"
    case electric = "Electric"
    case grounded = "Grounded"

    var icon: String {
        switch self {
        case .magnetic:  return "bolt.circle.fill"
        case .mellow:    return "moon.stars.fill"
        case .electric:  return "sparkles"
        case .grounded:  return "leaf.fill"
        }
    }
    var value: Double {
        switch self {
        case .magnetic:  return 0.82
        case .mellow:    return 0.48
        case .electric:  return 0.95
        case .grounded:  return 0.30
        }
    }
}

enum TimeType: String {
    case lateDeparture = "Late Departure"
    case goldenHour    = "Golden Hour"
    case allNighter    = "All-Nighter"
    case earlyBird     = "Early Bird"

    var icon: String {
        switch self {
        case .lateDeparture: return "clock.badge.exclamationmark.fill"
        case .goldenHour:    return "sunset.fill"
        case .allNighter:    return "moon.zzz.fill"
        case .earlyBird:     return "sunrise.fill"
        }
    }
}

enum SceneType: String {
    case rooftops   = "Rooftop Culture"
    case underground = "Underground Gems"
    case marquee    = "Marquee Moments"
    case intimate   = "Intimate Gatherings"

    var icon: String {
        switch self {
        case .rooftops:    return "building.2.fill"
        case .underground: return "theatermasks.fill"
        case .marquee:     return "star.fill"
        case .intimate:    return "house.fill"
        }
    }
}

enum ConnectionType: String {
    case bestFriendsForever = "BFF Builder"
    case networkExpander    = "Network Expander"
    case deepDiver          = "Deep Connector"
    case socialButterfly    = "Social Butterfly"

    var icon: String {
        switch self {
        case .bestFriendsForever: return "heart.circle.fill"
        case .networkExpander:    return "person.3.fill"
        case .deepDiver:          return "bubble.left.and.bubble.right.fill"
        case .socialButterfly:    return "hand.wave.fill"
        }
    }
}

struct DNATrait: Identifiable {
    let id = UUID()
    let label: String
    let value: Double     // 0.0 – 1.0
    let leftLabel: String
    let rightLabel: String
    let color: Color
}

// MARK: - Mock Data

private let mockDNA = SocialDNAProfile(
    userName: "Aidan",
    archetypeTitle: "The Magnetic Connector",
    archetypeSubtitle: "Rare — only 6% of Venn users",
    archetypeEmoji: "⚡",
    energyType: .magnetic,
    timeType: .lateDeparture,
    sceneType: .rooftops,
    connectionType: .networkExpander,
    traits: [
        DNATrait(label: "Energy",      value: 0.82, leftLabel: "Chill",   rightLabel: "Electric", color: VennColors.coral),
        DNATrait(label: "Scene",       value: 0.70, leftLabel: "Intimate", rightLabel: "Marquee",  color: VennColors.gold),
        DNATrait(label: "Timing",      value: 0.68, leftLabel: "Early",   rightLabel: "Late",     color: VennColors.indigo),
        DNATrait(label: "Connection",  value: 0.55, leftLabel: "Familiar", rightLabel: "New Faces", color: VennColors.success),
        DNATrait(label: "Planning",    value: 0.24, leftLabel: "Planned",  rightLabel: "Spontaneous", color: Color(hex: "#F97316"))
    ],
    compatibleWith: "The Curator",
    oppositeOf: "The Homebody",
    weekendMood: "\"Arrive late, leave last, text everyone Monday\"",
    primaryColor: VennColors.coral,
    secondaryColor: VennColors.gold
)

// MARK: - Root View

struct SocialDNAView: View {
    let profile: SocialDNAProfile
    @State private var appeared = false
    @State private var showShareSheet = false
    @State private var cardScale: CGFloat = 0.92
    @State private var activeSegment: Int = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            // Ambient background glows
            ambientBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Shareable card
                    shareableCard
                        .padding(.horizontal, 20)
                        .scaleEffect(appeared ? 1 : cardScale)
                        .opacity(appeared ? 1 : 0)
                        .animation(VennAnimation.bouncy.delay(0.1), value: appeared)

                    // DNA traits breakdown
                    traitsSection
                        .padding(.top, 32)
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(VennAnimation.gentle.delay(0.5), value: appeared)

                    // Type grid
                    typeGrid
                        .padding(.top, 28)
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(VennAnimation.gentle.delay(0.65), value: appeared)

                    // Compatibility row
                    compatibilityRow
                        .padding(.top, 28)
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(VennAnimation.gentle.delay(0.8), value: appeared)

                    // CTA buttons
                    ctaButtons
                        .padding(.top, 40)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 60)
                        .opacity(appeared ? 1 : 0)
                        .animation(VennAnimation.gentle.delay(0.95), value: appeared)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [
                "My Social DNA on Venn: \(profile.archetypeTitle) — \(profile.archetypeSubtitle). What's yours? #VennDNA"
            ])
        }
        .onAppear { appeared = true }
    }

    // MARK: - Ambient Background

    private var ambientBackground: some View {
        ZStack {
            RadialGradient(
                colors: [profile.primaryColor.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [profile.secondaryColor.opacity(0.12), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Social DNA")
                    .font(VennTypography.heading)
                    .foregroundColor(.white)
                Text("Your nightlife personality card")
                    .font(VennTypography.body)
                    .foregroundColor(VennColors.textSecondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(VennColors.textSecondary)
                    .padding(10)
                    .background(Circle().fill(VennColors.surfacePrimary))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 24)
    }

    // MARK: - Shareable Card

    private var shareableCard: some View {
        ZStack {
            // Card background with signature gradient
            RoundedRectangle(cornerRadius: VennRadius.xxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#1A0C06"),
                            Color(hex: "#120914"),
                            Color(hex: "#09090B")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Colored glow overlay inside card
            RoundedRectangle(cornerRadius: VennRadius.xxl, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [profile.primaryColor.opacity(0.22), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 260
                    )
                )

            RoundedRectangle(cornerRadius: VennRadius.xxl, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [profile.secondaryColor.opacity(0.14), .clear],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 200
                    )
                )

            // Border
            RoundedRectangle(cornerRadius: VennRadius.xxl, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            profile.primaryColor.opacity(0.45),
                            profile.secondaryColor.opacity(0.25),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )

            // Decorative DNA helix pattern
            DNAHelixDecoration(color: profile.primaryColor)
                .opacity(0.06)
                .clipShape(RoundedRectangle(cornerRadius: VennRadius.xxl, style: .continuous))

            VStack(spacing: 0) {
                // Top badge row
                HStack {
                    // Venn brand
                    Text("VENN")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .kerning(5)
                        .foregroundStyle(VennGradients.primary)

                    Spacer()

                    // Rarity badge
                    Text(profile.archetypeSubtitle)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(profile.primaryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(profile.primaryColor.opacity(0.15))
                                .overlay(Capsule().stroke(profile.primaryColor.opacity(0.35), lineWidth: 1))
                        )
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer().frame(height: 28)

                // Archetype emoji
                Text(profile.archetypeEmoji)
                    .font(.system(size: 64))
                    .shadow(color: profile.primaryColor.opacity(0.5), radius: 24, x: 0, y: 0)
                    .floating(range: -5, duration: 2.8)
                    .glow(color: profile.primaryColor, radius: 20, intensity: 0.4)

                Spacer().frame(height: 20)

                // Archetype title
                Text(profile.archetypeTitle)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, profile.primaryColor.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer().frame(height: 8)

                // Username
                Text("@\(profile.userName.lowercased())")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(VennColors.textSecondary)

                Spacer().frame(height: 28)

                // Mini trait bars inside card
                VStack(spacing: 12) {
                    ForEach(Array(profile.traits.prefix(3).enumerated()), id: \.offset) { index, trait in
                        CardTraitBar(trait: trait, appeared: appeared, delay: Double(index) * 0.1 + 0.3)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 28)

                // Type icons row
                HStack(spacing: 0) {
                    CardTypeIcon(
                        icon: profile.energyType.icon,
                        label: profile.energyType.rawValue,
                        color: VennColors.coral
                    )
                    Divider()
                        .frame(width: 1, height: 32)
                        .background(VennColors.borderSubtle)
                    CardTypeIcon(
                        icon: profile.timeType.icon,
                        label: profile.timeType.rawValue,
                        color: VennColors.gold
                    )
                    Divider()
                        .frame(width: 1, height: 32)
                        .background(VennColors.borderSubtle)
                    CardTypeIcon(
                        icon: profile.sceneType.icon,
                        label: profile.sceneType.rawValue,
                        color: VennColors.indigo
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                        .fill(VennColors.glassLight)
                        .overlay(
                            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                                .stroke(VennColors.borderSubtle, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                Spacer().frame(height: 20)

                // Weekend mood quote
                Text(profile.weekendMood)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
            }
        }
        .shadow(color: profile.primaryColor.opacity(0.22), radius: 40, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.5), radius: 24, x: 0, y: 8)
    }

    // MARK: - Traits Section

    private var traitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Your DNA Breakdown", icon: "waveform.path.ecg")

            VStack(spacing: 14) {
                ForEach(profile.traits) { trait in
                    FullTraitBar(trait: trait, appeared: appeared)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.xl, style: .continuous)
                    .fill(VennColors.surfacePrimary)
            )
        }
    }

    // MARK: - Type Grid

    private var typeGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Your Type", icon: "person.fill.badge.plus")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                TypeCard(
                    icon: profile.energyType.icon,
                    category: "Energy",
                    value: profile.energyType.rawValue,
                    color: VennColors.coral
                )
                TypeCard(
                    icon: profile.timeType.icon,
                    category: "Timing",
                    value: profile.timeType.rawValue,
                    color: VennColors.gold
                )
                TypeCard(
                    icon: profile.sceneType.icon,
                    category: "Scene",
                    value: profile.sceneType.rawValue,
                    color: VennColors.indigo
                )
                TypeCard(
                    icon: profile.connectionType.icon,
                    category: "Connection",
                    value: profile.connectionType.rawValue,
                    color: VennColors.success
                )
            }
        }
    }

    // MARK: - Compatibility Row

    private var compatibilityRow: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Compatibility", icon: "arrow.triangle.2.circlepath")

            HStack(spacing: 12) {
                CompatCard(
                    title: "Best Match",
                    archetype: profile.compatibleWith,
                    icon: "heart.fill",
                    color: VennColors.coral,
                    caption: "Great social chemistry"
                )
                CompatCard(
                    title: "Opposite",
                    archetype: profile.oppositeOf,
                    icon: "arrow.left.arrow.right",
                    color: VennColors.textSecondary,
                    caption: "Different frequencies"
                )
            }
        }
    }

    // MARK: - CTA Buttons

    private var ctaButtons: some View {
        VStack(spacing: 12) {
            Button {
                HapticManager.shared.impact(.medium)
                showShareSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                    Text("Share My Social DNA")
                }
                .vennButton()
            }
            .pulse(from: 1.0, to: 1.015, duration: 2.2)

            Button {
                HapticManager.shared.impact(.light)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Retake Personality Quiz")
                }
                .vennSecondaryButton()
            }
        }
    }
}

// MARK: - DNA Helix Decoration

private struct DNAHelixDecoration: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let steps = 24

            ZStack {
                // Left strand
                Path { path in
                    for i in 0...steps {
                        let t = CGFloat(i) / CGFloat(steps)
                        let x = w * 0.12 + sin(t * .pi * 4) * 28
                        let y = h * t
                        if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(color, lineWidth: 1.5)

                // Right strand
                Path { path in
                    for i in 0...steps {
                        let t = CGFloat(i) / CGFloat(steps)
                        let x = w * 0.88 + sin(t * .pi * 4 + .pi) * 28
                        let y = h * t
                        if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(color, lineWidth: 1.5)

                // Rungs
                ForEach(0..<steps, id: \.self) { i in
                    let t = CGFloat(i) / CGFloat(steps)
                    let x1 = w * 0.12 + sin(t * .pi * 4) * 28
                    let x2 = w * 0.88 + sin(t * .pi * 4 + .pi) * 28
                    let y = h * t

                    if i % 3 == 0 {
                        Path { path in
                            path.move(to: CGPoint(x: x1, y: y))
                            path.addLine(to: CGPoint(x: x2, y: y))
                        }
                        .stroke(color.opacity(0.6), lineWidth: 1)
                    }
                }
            }
        }
    }
}

// MARK: - Card Trait Bar (compact, for shareable card)

private struct CardTraitBar: View {
    let trait: DNATrait
    let appeared: Bool
    let delay: Double
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text(trait.label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(VennColors.textSecondary)
                Spacer()
                HStack(spacing: 4) {
                    Text(trait.leftLabel)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundColor(VennColors.textTertiary)
                    Text("·")
                        .foregroundColor(VennColors.textTertiary)
                    Text(trait.rightLabel)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(trait.value > 0.5 ? trait.color : VennColors.textTertiary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [trait.color.opacity(0.7), trait.color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.easeOut(duration: 0.9).delay(delay), value: progress)
                }
            }
            .frame(height: 4)
        }
        .onAppear {
            if appeared { progress = trait.value }
        }
        .onChange(of: appeared) { newValue in
            if newValue { progress = trait.value }
        }
    }
}

// MARK: - Full Trait Bar (detail section)

private struct FullTraitBar: View {
    let trait: DNATrait
    let appeared: Bool
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(trait.label)
                    .font(VennTypography.bodyMedium)
                    .foregroundColor(.white)

                Spacer()

                Text(trait.value > 0.5 ? trait.rightLabel : trait.leftLabel)
                    .font(VennTypography.captionBold)
                    .foregroundColor(trait.color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(VennColors.surfaceSecondary)
                        .frame(height: 8)

                    // Fill
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [trait.color.opacity(0.6), trait.color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 8)
                        .shadow(color: trait.color.opacity(0.4), radius: 4, x: 0, y: 0)
                        .animation(.easeOut(duration: 1.0).delay(0.1), value: progress)

                    // Dot marker
                    Circle()
                        .fill(.white)
                        .frame(width: 14, height: 14)
                        .offset(x: max(0, geo.size.width * progress - 7))
                        .shadow(color: trait.color.opacity(0.6), radius: 6, x: 0, y: 0)
                        .animation(.easeOut(duration: 1.0).delay(0.1), value: progress)
                }
            }
            .frame(height: 14)

            // End labels
            HStack {
                Text(trait.leftLabel)
                    .font(VennTypography.caption)
                    .foregroundColor(VennColors.textTertiary)
                Spacer()
                Text(trait.rightLabel)
                    .font(VennTypography.caption)
                    .foregroundColor(VennColors.textTertiary)
            }
        }
        .onAppear {
            if appeared { progress = trait.value }
        }
        .onChange(of: appeared) { newValue in
            if newValue { progress = trait.value }
        }
    }
}

// MARK: - Card Type Icon

private struct CardTypeIcon: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(VennColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Type Card (grid)

private struct TypeCard: View {
    let icon: String
    let category: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(category)
                    .font(VennTypography.caption)
                    .foregroundColor(VennColors.textSecondary)
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                .fill(VennColors.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - Compat Card

private struct CompatCard: View {
    let title: String
    let archetype: String
    let icon: String
    let color: Color
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
                Text(title)
                    .font(VennTypography.captionBold)
                    .foregroundColor(VennColors.textSecondary)
            }

            Text(archetype)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(caption)
                .font(VennTypography.caption)
                .foregroundColor(VennColors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                .fill(VennColors.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                        .stroke(color.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(VennGradients.primary)
            Text(title)
                .font(VennTypography.subheading)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("Social DNA") {
    SocialDNAView(profile: mockDNA)
}
