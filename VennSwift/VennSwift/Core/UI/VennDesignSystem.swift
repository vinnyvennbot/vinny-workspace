import SwiftUI

// MARK: - Venn Design System
// Clean, modern, confident dark mode. Zinc-based near-blacks, punchy coral accent.

// MARK: - Colors

enum VennColors {
    // MARK: Backgrounds
    /// Deepest background — zinc-950, almost pure black
    static let darkBg           = Color(hex: "#09090B")
    /// Primary surface for cards, panels
    static let surfacePrimary   = Color(hex: "#141416")
    /// Slightly elevated surface
    static let surfaceSecondary = Color(hex: "#1C1C1F")
    /// Even more elevated — drawers, overlays, modals
    static let surfaceTertiary  = Color(hex: "#262629")

    // MARK: Accent
    /// Primary accent — tomato red-orange, punchy
    static let coral        = Color(hex: "#FF6347")
    /// Secondary accent — bright warm amber
    static let gold         = Color(hex: "#FFB347")
    /// Tertiary accent — indigo for links, supplementary UI
    static let indigo       = Color(hex: "#818CF8")
    /// Coral at 0.12 opacity for subtle highlight backgrounds
    static let coralSubtle  = Color(hex: "#FF6347").opacity(0.12)
    /// Gold at 0.10 opacity for subtle highlight backgrounds
    static let goldSubtle   = Color(hex: "#FFB347").opacity(0.10)

    // MARK: Text
    /// Primary text — zinc-100
    static let textPrimary   = Color(hex: "#F4F4F5")
    /// Secondary text — zinc-400
    static let textSecondary = Color(hex: "#A1A1AA")
    /// Tertiary text — zinc-500
    static let textTertiary  = Color(hex: "#71717A")
    /// Disabled / placeholder — zinc-700
    static let textDisabled  = Color(hex: "#3F3F46")

    // MARK: Borders & Dividers — very subtle, used sparingly
    static let borderSubtle  = Color.white.opacity(0.04)
    static let borderMedium  = Color.white.opacity(0.08)
    static let borderStrong  = Color.white.opacity(0.14)

    // MARK: Semantic
    static let success = Color(hex: "#34D399")
    static let warning = Color(hex: "#FBBF24")
    static let error   = Color(hex: "#EF4444")

    // MARK: Glass overlay
    static let glassLight  = Color.white.opacity(0.04)
    static let glassMedium = Color.white.opacity(0.06)
}

// MARK: - Gradients

enum VennGradients {
    /// Primary brand gradient — coral to gold
    static let primary = LinearGradient(
        colors: [VennColors.coral, VennColors.gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle card gradient — surface to slightly lighter
    static let card = LinearGradient(
        colors: [VennColors.surfacePrimary, VennColors.surfaceSecondary],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Glass overlay gradient
    static let glass = LinearGradient(
        colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Radial glow — for hero/splash moments
    static let coralGlow = RadialGradient(
        colors: [VennColors.coral.opacity(0.22), Color.clear],
        center: .center,
        startRadius: 0,
        endRadius: 200
    )

    /// Dark overlay for images
    static let imageOverlay = LinearGradient(
        colors: [Color.black.opacity(0.0), Color.black.opacity(0.65)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography

enum VennTypography {
    // Display — for hero moments, splash screens
    static let displayLarge  = Font.system(size: 52, weight: .bold,    design: .rounded)
    static let displayMedium = Font.system(size: 40, weight: .bold,    design: .rounded)

    // Headings
    static let heading       = Font.system(size: 28, weight: .bold,    design: .rounded)
    static let subheading    = Font.system(size: 20, weight: .semibold, design: .rounded)

    // Body
    static let bodyLarge     = Font.system(size: 17, weight: .regular, design: .rounded)
    static let body          = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodyMedium    = Font.system(size: 15, weight: .medium,  design: .rounded)

    // Supporting
    static let caption       = Font.system(size: 12, weight: .regular,  design: .rounded)
    static let captionBold   = Font.system(size: 12, weight: .semibold, design: .rounded)

    // Navigation / Tab Pills
    static let pill          = Font.system(size: 12, weight: .bold,    design: .rounded)
    static let pillIcon      = Font.system(size: 13, weight: .semibold, design: .rounded)

    // Button
    static let buttonLabel   = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let buttonSmall   = Font.system(size: 14, weight: .semibold, design: .rounded)
}

// MARK: - Spacing

enum VennSpacing {
    static let xs:    CGFloat = 4
    static let sm:    CGFloat = 8
    static let md:    CGFloat = 12
    static let lg:    CGFloat = 16
    static let xl:    CGFloat = 20
    static let xxl:   CGFloat = 24
    static let xxxl:  CGFloat = 32
    static let huge:  CGFloat = 40
    static let massive: CGFloat = 48
}

// MARK: - Corner Radii

enum VennRadius {
    static let small:  CGFloat = 8
    static let medium: CGFloat = 12
    static let large:  CGFloat = 16
    static let xl:     CGFloat = 20
    static let xxl:    CGFloat = 24
    static let pill:   CGFloat = 999
}

// MARK: - Shadows

enum VennShadows {
    struct ShadowConfig {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    static let card = ShadowConfig(
        color: Color.black.opacity(0.35),
        radius: 20,
        x: 0,
        y: 8
    )

    static let elevated = ShadowConfig(
        color: Color.black.opacity(0.45),
        radius: 32,
        x: 0,
        y: 12
    )

    static let coralGlow = ShadowConfig(
        color: VennColors.coral.opacity(0.28),
        radius: 20,
        x: 0,
        y: 4
    )

    static let subtle = ShadowConfig(
        color: Color.black.opacity(0.20),
        radius: 8,
        x: 0,
        y: 2
    )
}

// MARK: - Animation Constants

enum VennAnimation {
    /// Standard page/modal transition
    static let standard = Animation.spring(response: 0.38, dampingFraction: 0.84)
    /// Snappy UI response — tab switches, toggles
    static let snappy   = Animation.spring(response: 0.28, dampingFraction: 0.80)
    /// Slow, deliberate — hero reveals, loading
    static let gentle   = Animation.spring(response: 0.55, dampingFraction: 0.90)
    /// Very quick micro-interaction
    static let micro    = Animation.spring(response: 0.18, dampingFraction: 0.75)
    /// Bounce — playful, success states
    static let bouncy   = Animation.spring(response: 0.40, dampingFraction: 0.60)
}

// MARK: - View Modifiers

// MARK: Card Modifier
// No border stroke — background color contrast provides sufficient definition.
struct VennCardModifier: ViewModifier {
    var padding: CGFloat = VennSpacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                    .fill(VennColors.surfacePrimary)
                    .shadow(
                        color: VennShadows.card.color,
                        radius: VennShadows.card.radius,
                        x: VennShadows.card.x,
                        y: VennShadows.card.y
                    )
            )
    }
}

// MARK: Glass Modifier
struct VennGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = VennRadius.large

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(VennColors.glassLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(VennColors.borderSubtle, lineWidth: 1)
                    )
            )
    }
}

// MARK: Primary Button Modifier
struct VennButtonModifier: ViewModifier {
    var isEnabled: Bool = true

    func body(content: Content) -> some View {
        content
            .font(VennTypography.buttonLabel)
            .foregroundColor(isEnabled ? VennColors.darkBg : VennColors.textDisabled)
            .frame(maxWidth: .infinity)
            .padding(.vertical, VennSpacing.lg)
            .background(
                Group {
                    if isEnabled {
                        AnyView(
                            RoundedRectangle(cornerRadius: VennRadius.pill, style: .continuous)
                                .fill(VennGradients.primary)
                                .shadow(
                                    color: VennShadows.coralGlow.color,
                                    radius: VennShadows.coralGlow.radius,
                                    x: 0,
                                    y: VennShadows.coralGlow.y
                                )
                        )
                    } else {
                        AnyView(
                            RoundedRectangle(cornerRadius: VennRadius.pill, style: .continuous)
                                .fill(VennColors.surfaceSecondary)
                        )
                    }
                }
            )
            .animation(VennAnimation.micro, value: isEnabled)
    }
}

// MARK: Secondary Button Modifier
struct VennSecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(VennTypography.buttonLabel)
            .foregroundColor(VennColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, VennSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.pill, style: .continuous)
                    .fill(VennColors.glassLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: VennRadius.pill, style: .continuous)
                            .stroke(VennColors.borderMedium, lineWidth: 1)
                    )
            )
    }
}

// MARK: - View Extension

extension View {
    func vennCard(padding: CGFloat = VennSpacing.lg) -> some View {
        modifier(VennCardModifier(padding: padding))
    }

    func vennGlass(cornerRadius: CGFloat = VennRadius.large) -> some View {
        modifier(VennGlassModifier(cornerRadius: cornerRadius))
    }

    func vennButton(isEnabled: Bool = true) -> some View {
        modifier(VennButtonModifier(isEnabled: isEnabled))
    }

    func vennSecondaryButton() -> some View {
        modifier(VennSecondaryButtonModifier())
    }
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .rotationEffect(.degrees(15))
                    .offset(x: phase * (geo.size.width + 200) - 100)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2.0)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1.0
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Pulse Effect

struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.7
    let duration: Double

    init(duration: Double = 1.8) {
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.04
                    opacity = 1.0
                }
            }
    }
}

extension View {
    func vennPulse(duration: Double = 1.8) -> some View {
        modifier(PulseModifier(duration: duration))
    }
}
