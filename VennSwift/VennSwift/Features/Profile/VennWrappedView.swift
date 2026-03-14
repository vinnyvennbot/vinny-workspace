import SwiftUI

// MARK: - VennWrappedView
// "Venn Wrapped" — Spotify Wrapped-style viral story experience.
// 8-page vertical swipe narrative. Designed to be screenshotted and shared.

// MARK: - Data Model

struct WrappedStats {
    let eventsAttended: Int
    let cityPercentile: Int
    let latestNight: String
    let averageWeekendTime: String
    let socialScore: Int
    let socialTitle: String
    let userPercentile: Int
    let topVibes: [(emoji: String, name: String, percentage: Int)]
    let bestFriend: (name: String, initial: String, eventsCount: Int, since: String)
    let archetype: String
    let archetypeDescription: String
    let archetypeRarity: Int

    static let mock = WrappedStats(
        eventsAttended: 47,
        cityPercentile: 94,
        latestNight: "3:47 AM",
        averageWeekendTime: "12:30 AM",
        socialScore: 87,
        socialTitle: "Social Butterfly",
        userPercentile: 6,
        topVibes: [
            (emoji: "🎵", name: "Live Music", percentage: 34),
            (emoji: "🍷", name: "Wine & Dine", percentage: 28),
            (emoji: "💃", name: "Dancing", percentage: 22)
        ],
        bestFriend: (name: "Mia", initial: "M", eventsCount: 14, since: "February"),
        archetype: "The Night Owl Explorer",
        archetypeDescription: "You don't just attend events — you curate experiences. From underground gigs to rooftop dinners, you move through your city with an effortless hunger for what's next. You're the first to find the hidden gem and the last to leave it.",
        archetypeRarity: 4
    )
}

// MARK: - Root View

struct VennWrappedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimatingTransition: Bool = false

    private let totalPages = 8
    private let stats = WrappedStats.mock

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {

                // Active page
                pageView(for: currentPage, size: geo.size)
                    .offset(y: dragOffset)
                    .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.86), value: dragOffset)

                // Progress pills — sits above page content
                WrappedProgressBar(current: currentPage, total: totalPages)
                    .padding(.top, geo.safeAreaInsets.top + 14)
                    .padding(.horizontal, VennSpacing.xl)

                // Close button
                Button {
                    Task { @MainActor in HapticManager.shared.impact(.light) }
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.white.opacity(0.14)))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, geo.safeAreaInsets.top + 10)
                .padding(.trailing, VennSpacing.xl)
            }
        }
        .ignoresSafeArea()
        .gesture(swipeGesture)
        .statusBarHidden(true)
    }

    // MARK: - Page Router

    @ViewBuilder
    private func pageView(for index: Int, size: CGSize) -> some View {
        switch index {
        case 0:  Page1IntroView(stats: stats)
        case 1:  Page2EventsView(stats: stats)
        case 2:  Page3LateNightsView(stats: stats)
        case 3:  Page4SocialScoreView(stats: stats)
        case 4:  Page5TopVibeView(stats: stats)
        case 5:  Page6BestFriendView(stats: stats)
        case 6:  Page7ArchetypeView(stats: stats)
        default: Page8ShareView(stats: stats, onDismiss: { dismiss() })
        }
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 14)
            .onChanged { value in
                guard !isAnimatingTransition else { return }
                let t = value.translation.height
                let atTop    = currentPage == 0 && t > 0
                let atBottom = currentPage == totalPages - 1 && t < 0
                dragOffset = (atTop || atBottom) ? t * 0.16 : t * 0.44
            }
            .onEnded { value in
                guard !isAnimatingTransition else { return }
                let velocity = value.predictedEndTranslation.height
                if velocity < -60 && currentPage < totalPages - 1 {
                    navigateToPage(currentPage + 1)
                } else if velocity > 60 && currentPage > 0 {
                    navigateToPage(currentPage - 1)
                } else {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func navigateToPage(_ page: Int) {
        isAnimatingTransition = true
        Task { @MainActor in HapticManager.shared.impact(.light) }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            dragOffset = 0
            currentPage = page
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimatingTransition = false
        }
    }
}

// MARK: - Progress Bar

private struct WrappedProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index <= current ? Color.white : Color.white.opacity(0.25))
                    .frame(height: 3)
                    .animation(.spring(response: 0.38, dampingFraction: 0.82), value: current)
            }
        }
    }
}

// MARK: - Particle System

private struct FloatingParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let delay: Double
    let color: Color
}

private struct ParticleField: View {
    let particles: [FloatingParticle]
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .opacity(animate ? p.opacity : 0)
                        .position(
                            x: p.x * geo.size.width,
                            y: animate
                                ? (p.y * geo.size.height) - 28
                                : (p.y * geo.size.height) + 28
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 3.5...6.0))
                            .repeatForever(autoreverses: true)
                            .delay(p.delay),
                            value: animate
                        )
                }
            }
        }
        .onAppear { animate = true }
    }

    static func make(count: Int, colors: [Color]) -> [FloatingParticle] {
        (0..<count).map { _ in
            FloatingParticle(
                x: CGFloat.random(in: 0.03...0.97),
                y: CGFloat.random(in: 0.05...0.95),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.22...0.62),
                delay: Double.random(in: 0...3.5),
                color: colors.randomElement() ?? .white
            )
        }
    }
}

// MARK: - Glassmorphic Pill

private struct GlassPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.11))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Animated Counter

private struct AnimatedCounter: View {
    let target: Int
    let duration: Double
    @State private var displayed: Int = 0
    @State private var hasAnimated = false

    var body: some View {
        Text("\(displayed)")
            .contentTransition(.numericText())
            .onAppear {
                guard !hasAnimated else { return }
                hasAnimated = true
                let steps = 44
                let stepDuration = duration / Double(steps)
                for i in 0...steps {
                    let delay = stepDuration * Double(i)
                    let progress = Double(i) / Double(steps)
                    let eased = 1 - pow(1 - progress, 3) // cubic ease-out
                    let value = Int(eased * Double(target))
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.easeOut(duration: stepDuration)) {
                            displayed = value
                        }
                    }
                }
            }
    }
}

// MARK: - Emoji Rain

private struct EmojiRainView: View {
    let emojis: [String]
    @State private var drops: [EmojiDrop] = []

    struct EmojiDrop: Identifiable {
        let id = UUID()
        let emoji: String
        let x: CGFloat
        let startYFraction: CGFloat
        let size: CGFloat
        let duration: Double
        let delay: Double
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(drops) { drop in
                    EmojiDropAnimator(drop: drop, containerHeight: geo.size.height)
                        .position(x: drop.x * geo.size.width, y: drop.startYFraction * geo.size.height)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            drops = (0..<14).map { _ in
                EmojiDrop(
                    emoji: emojis.randomElement() ?? "🎉",
                    x: CGFloat.random(in: 0.05...0.95),
                    startYFraction: CGFloat.random(in: -0.05...0.1),
                    size: CGFloat.random(in: 18...34),
                    duration: Double.random(in: 6...10),
                    delay: Double.random(in: 0...3.5)
                )
            }
        }
    }
}

private struct EmojiDropAnimator: View {
    let drop: EmojiRainView.EmojiDrop
    let containerHeight: CGFloat
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        Text(drop.emoji)
            .font(.system(size: drop.size))
            .opacity(opacity * 0.42)
            .offset(y: yOffset)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + drop.delay) {
                    withAnimation(.easeIn(duration: 0.6)) { opacity = 1 }
                    withAnimation(.linear(duration: drop.duration).repeatForever(autoreverses: false)) {
                        yOffset = containerHeight * 1.1
                    }
                }
            }
    }
}

// MARK: ============================================================
// MARK: - PAGE 1: Intro
// MARK: ============================================================

private struct Page1IntroView: View {
    let stats: WrappedStats
    @State private var appeared = false
    @State private var yearRotation: Double = -4.0
    private let particles = ParticleField.make(
        count: 34,
        colors: [.white, VennColors.coral.opacity(0.7), VennColors.indigo.opacity(0.65)]
    )

    var body: some View {
        ZStack {
            // Coral-to-indigo diagonal
            LinearGradient(
                colors: [
                    Color(hex: "#1A0A1A"),
                    Color(hex: "#2B1060"),
                    VennColors.coral.opacity(0.52),
                    VennColors.indigo
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [VennColors.coral.opacity(0.26), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 320
            )
            .ignoresSafeArea()

            ParticleField(particles: particles).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Watermark
                Text("VENN")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .tracking(8)
                    .foregroundColor(.white.opacity(0.17))
                    .padding(.bottom, 36)
                    .offset(y: appeared ? 0 : 10)
                    .opacity(appeared ? 1 : 0)

                // Year — ultra bold, slight rotation
                Text("2025")
                    .font(.system(size: 116, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(yearRotation))
                    .shimmer(duration: 3.2)
                    .scaleEffect(appeared ? 1.0 : 0.68)
                    .opacity(appeared ? 1.0 : 0.0)
                    .shadow(color: VennColors.coral.opacity(0.48), radius: 44, x: 0, y: 0)

                // WRAPPED — letter-spaced gradient
                Text("WRAPPED")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .tracking(14)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [VennColors.coral, VennColors.gold, VennColors.indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.top, -6)
                    .offset(y: appeared ? 0 : 22)
                    .opacity(appeared ? 1 : 0)

                // Rule
                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 48, height: 1)
                    .padding(.vertical, 28)
                    .scaleEffect(x: appeared ? 1 : 0)

                // Tagline
                Text("Your year, by the numbers.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                Spacer()

                // Swipe hint
                VStack(spacing: 8) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.48))
                        .floating(range: -6, duration: 1.4)
                    Text("Swipe up to begin")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.38))
                        .pulse(from: 0.5, to: 0.9, duration: 1.9)
                }
                .padding(.bottom, 56)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            Task { @MainActor in HapticManager.shared.impact(.medium) }
            withAnimation(.spring(response: 0.72, dampingFraction: 0.72).delay(0.1)) { appeared = true }
            withAnimation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true)) { yearRotation = 4.0 }
        }
    }
}

// MARK: ============================================================
// MARK: - PAGE 2: Events Attended
// MARK: ============================================================

private struct Page2EventsView: View {
    let stats: WrappedStats
    @State private var appeared = false
    private let particles = ParticleField.make(
        count: 18,
        colors: [VennColors.coral.opacity(0.9), VennColors.gold.opacity(0.65), Color.white.opacity(0.45)]
    )

    var body: some View {
        ZStack {
            // Fire gradient — bottom-up ember glow
            LinearGradient(
                colors: [Color(hex: "#0D0505"), Color(hex: "#1A0808"), VennColors.coral.opacity(0.68)],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [VennColors.coral.opacity(0.44), VennColors.gold.opacity(0.18), Color.clear],
                center: .bottom,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()

            // Emoji rain
            EmojiRainView(emojis: ["🎉", "🎊", "✨", "🥳", "🎈"])

            ParticleField(particles: particles).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("THIS YEAR, YOU ATTENDED")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.white.opacity(0.52))
                    .opacity(appeared ? 1 : 0)
                    .padding(.bottom, 16)

                // Enormous counter
                Group {
                    if appeared {
                        AnimatedCounter(target: stats.eventsAttended, duration: 1.4)
                            .font(.system(size: 130, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: VennColors.coral.opacity(0.58), radius: 52, x: 0, y: 0)
                    } else {
                        Text("0")
                            .font(.system(size: 130, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(appeared ? 1 : 0.58)
                .opacity(appeared ? 1 : 0)

                Text("events attended")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.84))
                    .padding(.top, -6)
                    .offset(y: appeared ? 0 : 16)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 44)

                GlassPill(text: "More than \(stats.cityPercentile)% of your city")
                    .scaleEffect(appeared ? 1 : 0.82)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                Text("Keep showing up. Your city knows your name.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.42))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 64)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            Task { @MainActor in HapticManager.shared.impact(.heavy) }
            withAnimation(.spring(response: 0.66, dampingFraction: 0.74).delay(0.08)) { appeared = true }
        }
    }
}

// MARK: ============================================================
// MARK: - PAGE 3: Late Nights
// MARK: ============================================================

private struct Page3LateNightsView: View {
    let stats: WrappedStats
    @State private var appeared = false
    @State private var clockProgress: Double = 0
    private let particles = ParticleField.make(
        count: 30,
        colors: [Color.white.opacity(0.55), VennColors.indigo.opacity(0.48), Color(hex: "#C084FC").opacity(0.38)]
    )

    var body: some View {
        ZStack {
            // Deep nebula
            LinearGradient(
                colors: [
                    Color(hex: "#030310"),
                    Color(hex: "#0D0830"),
                    Color(hex: "#1E0A5E"),
                    Color(hex: "#2D1472")
                ],
                startPoint: .bottom,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [VennColors.indigo.opacity(0.34), Color(hex: "#C084FC").opacity(0.11), Color.clear],
                center: UnitPoint(x: 0.7, y: 0.28),
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()

            ParticleField(particles: particles).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("🌙")
                    .font(.system(size: 52))
                    .floating(range: -10, duration: 3.0)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.38)

                Spacer().frame(height: 30)

                // Clock visualization
                ClockArcView(progress: clockProgress, timeLabel: stats.latestNight)
                    .frame(width: 210, height: 210)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.55)

                Spacer().frame(height: 36)

                VStack(spacing: 10) {
                    Text("YOUR LATEST NIGHT")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.48))

                    Text(stats.latestNight)
                        .font(.system(size: 70, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shimmer(duration: 3.6)
                        .shadow(color: VennColors.indigo.opacity(0.68), radius: 38, x: 0, y: 0)
                }
                .scaleEffect(appeared ? 1 : 0.72)
                .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 28)

                GlassPill(text: "Weekend avg: \(stats.averageWeekendTime)")
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)

                Spacer()

                Text("The city never sleeps, and neither do you.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.38))
                    .padding(.bottom, 64)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            Task { @MainActor in HapticManager.shared.impact(.medium) }
            withAnimation(.spring(response: 0.72, dampingFraction: 0.78).delay(0.1)) { appeared = true }
            withAnimation(.easeOut(duration: 1.5).delay(0.42)) { clockProgress = 0.82 }
        }
    }
}

// MARK: - Clock Arc

private struct ClockArcView: View {
    let progress: Double
    let timeLabel: String

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: 7)

            // Gradient arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [VennColors.indigo, Color(hex: "#C084FC"), VennColors.coral],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Hour tick marks
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.white.opacity(i % 3 == 0 ? 0.44 : 0.16))
                    .frame(width: i % 3 == 0 ? 2 : 1, height: i % 3 == 0 ? 10 : 6)
                    .offset(y: -91)
                    .rotationEffect(.degrees(Double(i) * 30))
            }

            // Center label
            VStack(spacing: 2) {
                Text("3:47")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("AM")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(3)
                    .foregroundColor(VennColors.indigo)
            }

            // Tip dot
            Circle()
                .fill(VennColors.coral)
                .frame(width: 10, height: 10)
                .offset(y: -87)
                .rotationEffect(.degrees(progress * 360 - 90))
                .glow(color: VennColors.coral, radius: 8, intensity: 0.8)
        }
    }
}

// MARK: ============================================================
// MARK: - PAGE 4: Social Score
// MARK: ============================================================

private struct Page4SocialScoreView: View {
    let stats: WrappedStats
    @State private var appeared = false
    @State private var ringProgress: Double = 0

    var body: some View {
        ZStack {
            // Prestige dark
            LinearGradient(
                colors: [Color(hex: "#080810"), Color(hex: "#0F0C22"), Color(hex: "#1A1040")],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [VennColors.gold.opacity(0.15), VennColors.coral.opacity(0.09), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("YOUR SOCIAL SCORE")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.white.opacity(0.43))
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 40)

                SocialScoreRingView(progress: ringProgress, score: stats.socialScore)
                    .frame(width: 248, height: 248)
                    .scaleEffect(appeared ? 1 : 0.48)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 40)

                // Title
                Text(stats.socialTitle)
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [VennColors.gold, VennColors.coral],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shimmer(duration: 2.6)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer().frame(height: 20)

                // Percentile badge
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(VennColors.gold)
                    Text("Top \(stats.userPercentile)% of Venn users")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(VennColors.gold.opacity(0.14))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(VennColors.gold.opacity(0.28), lineWidth: 1)
                        )
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

                Spacer()

                Text("You outshine the crowd — and you know it.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.36))
                    .padding(.bottom, 64)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            Task { @MainActor in HapticManager.shared.impact(.heavy) }
            withAnimation(.spring(response: 0.66, dampingFraction: 0.78).delay(0.08)) { appeared = true }
            withAnimation(.easeOut(duration: 1.4).delay(0.36)) { ringProgress = Double(stats.socialScore) / 100.0 }
        }
    }
}

// MARK: - Score Ring

private struct SocialScoreRingView: View {
    let progress: Double
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: 17)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [VennColors.coral, VennColors.gold, VennColors.indigo, Color(hex: "#C084FC"), VennColors.coral],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 17, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: VennColors.gold.opacity(0.48), radius: 14, x: 0, y: 0)

            // Center score
            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 58, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("out of 100")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.42))
            }

            // Glowing tip dot
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
                .offset(y: -116)
                .rotationEffect(.degrees(progress * 360 - 90))
                .glow(color: .white, radius: 10, intensity: 0.85)
        }
    }
}

// MARK: ============================================================
// MARK: - PAGE 5: Top Vibe
// MARK: ============================================================

private struct Page5TopVibeView: View {
    let stats: WrappedStats
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Warm gold
            LinearGradient(
                colors: [Color(hex: "#0E0800"), Color(hex: "#1C1000"), Color(hex: "#3D2200"), VennColors.gold.opacity(0.48)],
                startPoint: .bottom,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [VennColors.gold.opacity(0.30), VennColors.coral.opacity(0.16), Color.clear],
                center: UnitPoint(x: 0.5, y: 0.28),
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("YOUR TOP VIBE")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.white.opacity(0.48))
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 22)

                // Dominant emoji — large and floating
                Text(stats.topVibes[0].emoji)
                    .font(.system(size: 82))
                    .scaleEffect(appeared ? 1 : 0.28)
                    .opacity(appeared ? 1 : 0)
                    .floating(range: -8, duration: 2.6)

                Spacer().frame(height: 14)

                Text(stats.topVibes[0].name)
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shimmer(duration: 3.0)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 18)

                Spacer().frame(height: 44)

                // Stacked vibe cards with rotational offsets
                ZStack {
                    ForEach(Array(stats.topVibes.enumerated().reversed()), id: \.offset) { index, vibe in
                        VibeCard(vibe: vibe, rank: index + 1)
                            .rotationEffect(.degrees(index == 0 ? 0 : index == 1 ? -3.5 : 3.8))
                            .offset(y: CGFloat(index) * -7)
                            .scaleEffect(1 - CGFloat(index) * 0.04)
                            .zIndex(Double(stats.topVibes.count - index))
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 42)
                            .animation(
                                .spring(response: 0.65, dampingFraction: 0.76)
                                    .delay(Double(index) * 0.12 + 0.2),
                                value: appeared
                            )
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                Text("You know exactly what moves you.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.36))
                    .padding(.bottom, 64)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            Task { @MainActor in HapticManager.shared.impact(.medium) }
            withAnimation(.spring(response: 0.64, dampingFraction: 0.76).delay(0.08)) { appeared = true }
        }
    }
}

// MARK: - Vibe Card

private struct VibeCard: View {
    let vibe: (emoji: String, name: String, percentage: Int)
    let rank: Int

    var body: some View {
        HStack(spacing: 16) {
            Text(vibe.emoji)
                .font(.system(size: 28))
                .frame(width: 46, height: 46)
                .background(Circle().fill(Color.white.opacity(0.10)))

            VStack(alignment: .leading, spacing: 5) {
                Text(vibe.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.09))
                            .frame(height: 4)
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [VennColors.gold, VennColors.coral],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(vibe.percentage) / 100.0, height: 4)
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            Text("\(vibe.percentage)%")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(VennColors.gold)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.13), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.38), radius: 20, x: 0, y: 10)
    }
}

// MARK: ============================================================
// MARK: - PAGE 6: Best Friend
// MARK: ============================================================

private struct Page6BestFriendView: View {
    let stats: WrappedStats
    @State private var appeared = false
    @State private var ringScale: CGFloat = 0.28
    private let particles = ParticleField.make(
        count: 14,
        colors: [VennColors.coral.opacity(0.45), Color(hex: "#FF8FAB").opacity(0.38), Color.white.opacity(0.28)]
    )

    var body: some View {
        ZStack {
            // Warm rose on dark
            LinearGradient(
                colors: [
                    Color(hex: "#0C0608"),
                    Color(hex: "#1C080E"),
                    Color(hex: "#3A0F1C"),
                    Color(hex: "#5C1830").opacity(0.78)
                ],
                startPoint: .bottom,
                endPoint: .topLeading
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [VennColors.coral.opacity(0.26), Color(hex: "#FF8FAB").opacity(0.13), Color.clear],
                center: UnitPoint(x: 0.5, y: 0.36),
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()

            ParticleField(particles: particles).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("YOUR PERSON")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.white.opacity(0.44))
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 36)

                // Avatar with concentric glow rings
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(VennColors.coral.opacity(0.11 - Double(i) * 0.03), lineWidth: 1)
                            .frame(
                                width: CGFloat(116 + i * 22),
                                height: CGFloat(116 + i * 22)
                            )
                            .scaleEffect(ringScale)
                            .animation(
                                .spring(response: 0.72, dampingFraction: 0.6).delay(Double(i) * 0.11 + 0.18),
                                value: ringScale
                            )
                    }

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [VennColors.coral, VennColors.gold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 108, height: 108)
                        .overlay(
                            Text(stats.bestFriend.initial)
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .glow(color: VennColors.coral, radius: 28, intensity: 0.52)
                        .scaleEffect(ringScale)
                        .animation(.spring(response: 0.66, dampingFraction: 0.7).delay(0.1), value: ringScale)
                }

                Spacer().frame(height: 36)

                VStack(spacing: 12) {
                    Text("You went out with")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.58))

                    Text(stats.bestFriend.name)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [VennColors.coral, VennColors.gold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shimmer(duration: 2.8)

                    Text("the most this year")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.58))
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                Spacer().frame(height: 28)

                HStack(spacing: 12) {
                    GlassPill(text: "\(stats.bestFriend.eventsCount) events together")
                    GlassPill(text: "Since \(stats.bestFriend.since)")
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)

                Spacer()

                Text("Partner in crime. Zero explanation needed.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.34))
                    .padding(.bottom, 64)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            Task { @MainActor in HapticManager.shared.impact(.medium) }
            withAnimation(.spring(response: 0.66, dampingFraction: 0.74).delay(0.08)) {
                appeared = true
                ringScale = 1.0
            }
        }
    }
}

// MARK: ============================================================
// MARK: - PAGE 7: Archetype  (THE most shareable page)
// MARK: ============================================================

private struct Page7ArchetypeView: View {
    let stats: WrappedStats
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Pure prestige gold
            LinearGradient(
                colors: [Color(hex: "#080600"), Color(hex: "#140E00"), Color(hex: "#2A1C00"), Color(hex: "#3D2800")],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [VennColors.gold.opacity(0.36), VennColors.coral.opacity(0.16), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 430
            )
            .ignoresSafeArea()

            ParticleField(
                particles: ParticleField.make(
                    count: 24,
                    colors: [Color.white.opacity(0.48), VennColors.gold.opacity(0.55)]
                )
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Crown
                Text("👑")
                    .font(.system(size: 46))
                    .floating(range: -6, duration: 2.8)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.28)

                Spacer().frame(height: 22)

                Text("YOUR ARCHETYPE")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.white.opacity(0.4))
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 18)

                // The main title — screenshot-perfect
                Text(stats.archetype)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, VennColors.gold, VennColors.coral, VennColors.gold, Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .shimmer(duration: 2.2, offset: 320)
                    .scaleEffect(appeared ? 1 : 0.68)
                    .opacity(appeared ? 1 : 0)
                    .shadow(color: VennColors.gold.opacity(0.56), radius: 34, x: 0, y: 0)

                Spacer().frame(height: 28)

                // Description card with animated border
                ArchetypeDescriptionCard(description: stats.archetypeDescription, appeared: appeared)
                    .padding(.horizontal, 28)

                Spacer().frame(height: 26)

                // Rarity badge
                RarityBadge(rarity: stats.archetypeRarity, appeared: appeared)

                Spacer()

                // Venn brand lockup
                HStack(spacing: 6) {
                    Text("VENN")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.28))
                    Text("2025 Wrapped")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.2))
                }
                .padding(.bottom, 56)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            Task { @MainActor in HapticManager.shared.success() }
            withAnimation(.spring(response: 0.72, dampingFraction: 0.74).delay(0.05)) { appeared = true }
        }
    }
}

// MARK: - Archetype Description Card

private struct ArchetypeDescriptionCard: View {
    let description: String
    let appeared: Bool
    @State private var borderAngle: Double = 0

    var body: some View {
        Text(description)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.055))

                    // Rotating gradient border
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    VennColors.gold.opacity(0.7),
                                    VennColors.coral.opacity(0.38),
                                    Color.clear,
                                    VennColors.gold.opacity(0.48),
                                    VennColors.coral.opacity(0.28),
                                    Color.clear,
                                    VennColors.gold.opacity(0.7)
                                ],
                                center: .center,
                                angle: .degrees(borderAngle)
                            ),
                            lineWidth: 1.2
                        )
                }
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 22)
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                    borderAngle = 360
                }
            }
    }
}

// MARK: - Rarity Badge

private struct RarityBadge: View {
    let rarity: Int
    let appeared: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(VennColors.gold.opacity(0.18))
                    .frame(width: 32, height: 32)
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(VennColors.gold)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("ULTRA RARE")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .tracking(2.5)
                    .foregroundColor(VennColors.gold.opacity(0.74))
                Text("Only \(rarity)% of Venn users share this archetype")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule(style: .continuous)
                .fill(VennColors.gold.opacity(0.11))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(VennColors.gold.opacity(0.33), lineWidth: 1)
                )
        )
        .glow(color: VennColors.gold, radius: 16, intensity: 0.33)
        .scaleEffect(appeared ? 1 : 0.72)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.62, dampingFraction: 0.72).delay(0.46), value: appeared)
    }
}

// MARK: ============================================================
// MARK: - PAGE 8: Share CTA
// MARK: ============================================================

private struct Page8ShareView: View {
    let stats: WrappedStats
    let onDismiss: () -> Void
    @State private var appeared = false
    @State private var sharePressed = false
    @State private var savePressed = false

    var body: some View {
        ZStack {
            // Coral burst
            LinearGradient(
                colors: [
                    Color(hex: "#0D0402"),
                    Color(hex: "#1F0906"),
                    VennColors.coral.opacity(0.64),
                    VennColors.gold.opacity(0.42)
                ],
                startPoint: .bottom,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [VennColors.coral.opacity(0.52), VennColors.gold.opacity(0.2), Color.clear],
                center: UnitPoint(x: 0.5, y: 0.26),
                startRadius: 0,
                endRadius: 410
            )
            .ignoresSafeArea()

            EmojiOrbitView()

            VStack(spacing: 0) {
                Spacer()

                // Header
                VStack(spacing: 6) {
                    Text("VENN WRAPPED 2025")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.52))
                    Text("Your year, shared.")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                Spacer().frame(height: 34)

                // Summary card
                WrappedSummaryCard(stats: stats)
                    .padding(.horizontal, 28)
                    .scaleEffect(appeared ? 1 : 0.86)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 34)

                // CTA buttons
                VStack(spacing: 12) {
                    // Primary: Share to Stories
                    Button {
                        Task { @MainActor in HapticManager.shared.success() }
                        sharePressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { sharePressed = false }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .bold))
                            Text("Share to Stories")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "#09090B"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: VennRadius.pill, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [VennColors.coral, VennColors.gold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: VennColors.coral.opacity(0.52), radius: 26, x: 0, y: 6)
                        )
                    }
                    .scaleEffect(sharePressed ? 0.96 : 1.0)
                    .animation(.spring(response: 0.24, dampingFraction: 0.64), value: sharePressed)

                    // Secondary: Save Image
                    Button {
                        Task { @MainActor in HapticManager.shared.impact(.light) }
                        savePressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { savePressed = false }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Save Image")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: VennRadius.pill, style: .continuous)
                                .fill(Color.white.opacity(0.11))
                                .overlay(
                                    RoundedRectangle(cornerRadius: VennRadius.pill, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .scaleEffect(savePressed ? 0.96 : 1.0)
                    .animation(.spring(response: 0.24, dampingFraction: 0.64), value: savePressed)
                }
                .padding(.horizontal, 28)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 22)

                Spacer().frame(height: 18)

                // Brand lockup
                VStack(spacing: 4) {
                    Text("Discover more on VENN")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.33))
                    Text("venn.app")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.44))
                }
                .padding(.bottom, 54)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            Task { @MainActor in HapticManager.shared.success() }
            withAnimation(.spring(response: 0.66, dampingFraction: 0.76).delay(0.08)) { appeared = true }
        }
    }
}

// MARK: - Wrapped Summary Card

private struct WrappedSummaryCard: View {
    let stats: WrappedStats

    var body: some View {
        VStack(spacing: 20) {
            // Header row
            HStack {
                Text("VENN")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [VennColors.coral, VennColors.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                Text("2025")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.42))
            }

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            // Stats trio
            HStack(spacing: 0) {
                SummaryStatItem(value: "\(stats.eventsAttended)", label: "Events")
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 1, height: 44)
                SummaryStatItem(value: "\(stats.socialScore)", label: "Score")
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 1, height: 44)
                SummaryStatItem(value: "Top \(stats.userPercentile)%", label: "City Rank")
            }

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            // Archetype row
            HStack(spacing: 12) {
                Text("👑")
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Archetype")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.42))
                    Text(stats.archetype)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("\(stats.archetypeRarity)% rare")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(VennColors.gold.opacity(0.14))
                    )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.44))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.11), lineWidth: 1)
                )
        )
    }
}

// MARK: - Summary Stat Item

private struct SummaryStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.42))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Emoji Orbit Ring (Page 8 decoration)

private struct EmojiOrbitView: View {
    private struct OrbitItem {
        let emoji: String
        let angle: Double
        let radius: CGFloat
    }

    private let items: [OrbitItem] = [
        OrbitItem(emoji: "🎉", angle: 0,   radius: 144),
        OrbitItem(emoji: "🎊", angle: 45,  radius: 156),
        OrbitItem(emoji: "✨", angle: 90,  radius: 142),
        OrbitItem(emoji: "🎵", angle: 135, radius: 154),
        OrbitItem(emoji: "🥳", angle: 180, radius: 143),
        OrbitItem(emoji: "🍷", angle: 225, radius: 152),
        OrbitItem(emoji: "💫", angle: 270, radius: 145),
        OrbitItem(emoji: "🎈", angle: 315, radius: 150)
    ]

    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.3
            ZStack {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    let rad = (item.angle + rotation) * .pi / 180
                    Text(item.emoji)
                        .font(.system(size: 22))
                        .opacity(0.33)
                        .position(
                            x: cx + cos(rad) * item.radius,
                            y: cy + sin(rad) * item.radius
                        )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Preview

#Preview("Venn Wrapped") {
    VennWrappedView()
}
