import SwiftUI
import MapKit
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Main Onboarding Flow

struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        ZStack {
            // Persistent animated background — hidden behind map on location phase
            if viewModel.phase != .location {
                OnboardingBackground(phase: viewModel.phase)
                    .ignoresSafeArea()
            }

            switch viewModel.phase {
            case .hook:
                HookPhaseView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            case .location:
                LocationPhaseView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
            case .conversation:
                ConversationPhaseView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
            case .reveal:
                RevealPhaseView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            }
        }
        .animation(VennAnimation.gentle, value: viewModel.phase)
    }
}

// MARK: - Animated Background

private struct OnboardingBackground: View {
    let phase: OnboardingViewModel.Phase

    // Dark base color — fully opaque, no transparency anywhere
    private static let dark = Color(red: 0.035, green: 0.035, blue: 0.043)

    @State private var meshPoints: [SIMD2<Float>] = OnboardingBackground.basePoints

    static let basePoints: [SIMD2<Float>] = [
        // Extend corners beyond 0...1 to prevent any edge gaps
        SIMD2(-0.1, -0.1), SIMD2(0.5, -0.1), SIMD2(1.1, -0.1),
        SIMD2(-0.1,  0.5), SIMD2(0.5,  0.5), SIMD2(1.1,  0.5),
        SIMD2(-0.1,  1.1), SIMD2(0.5,  1.1), SIMD2(1.1,  1.1),
    ]

    // All colors fully opaque — very dark with subtle tints mixed into the dark base
    private var gradientColors: [Color] {
        switch phase {
        case .hook:
            return [
                Self.dark,
                Self.dark,
                Self.dark,
                Color(red: 0.07, green: 0.04, blue: 0.03),   // warm hint left
                Color(red: 0.10, green: 0.05, blue: 0.03),   // subtle coral center
                Color(red: 0.06, green: 0.04, blue: 0.03),   // warm hint right
                Self.dark,
                Color(red: 0.07, green: 0.05, blue: 0.02),   // gold hint bottom
                Self.dark,
            ]
        case .location:
            return [
                Self.dark, Self.dark, Self.dark,
                Self.dark,
                Color(red: 0.06, green: 0.04, blue: 0.03),
                Self.dark,
                Self.dark, Self.dark, Self.dark,
            ]
        case .conversation:
            return [
                Self.dark,
                Self.dark,
                Self.dark,
                Color(red: 0.04, green: 0.04, blue: 0.08),   // indigo hint left
                Color(red: 0.05, green: 0.04, blue: 0.10),   // indigo center
                Color(red: 0.04, green: 0.03, blue: 0.07),   // indigo hint right
                Self.dark,
                Color(red: 0.05, green: 0.03, blue: 0.04),   // coral whisper bottom
                Self.dark,
            ]
        case .reveal:
            return [
                Self.dark,
                Self.dark,
                Self.dark,
                Color(red: 0.08, green: 0.04, blue: 0.03),   // warm left
                Color(red: 0.14, green: 0.06, blue: 0.03),   // coral center — brightest moment
                Color(red: 0.08, green: 0.05, blue: 0.02),   // gold right
                Self.dark,
                Color(red: 0.09, green: 0.06, blue: 0.02),   // gold bottom
                Self.dark,
            ]
        }
    }

    // Only jitter the center point — edges and corners stay locked
    private static func jitteredPoints() -> [SIMD2<Float>] {
        basePoints.enumerated().map { index, base in
            guard index == 4 else { return base } // only center moves
            return SIMD2(
                base.x + Float.random(in: -0.08...0.08),
                base.y + Float.random(in: -0.08...0.08)
            )
        }
    }

    var body: some View {
        ZStack {
            // Solid dark base to prevent any white bleed-through
            Self.dark.ignoresSafeArea()

            SwiftUI.MeshGradient(
                width: 3,
                height: 3,
                points: meshPoints,
                colors: gradientColors
            )
            .ignoresSafeArea()
        }
        .animation(VennAnimation.gentle, value: phase)
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                meshPoints = OnboardingBackground.jitteredPoints()
            }
        }
    }
}

// MARK: - Phase 1: The Hook

private struct HookPhaseView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var titleVisible = false
    @State private var statsVisible = false
    @State private var ctaVisible = false
    @State private var glowScale: CGFloat = 0.4
    @State private var glowOpacity: Double = 0
    @State private var ctaTapped = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Central glow seed + title
            VStack(spacing: VennSpacing.lg) {
                Text("Your city\nnever sleeps")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.clear)
                    .overlay(
                        LinearGradient(
                            colors: [VennColors.coral, VennColors.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Text("Your city\nnever sleeps")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                        )
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 20)
                    .visualEffect { content, proxy in
                        content
                            .offset(y: -proxy.frame(in: .global).minY * 0.1)
                    }

                Text("and neither should you")
                    .font(VennTypography.bodyLarge)
                    .foregroundColor(VennColors.textSecondary)
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 12)
            }
            .background(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                VennColors.coral.opacity(0.25),
                                VennColors.gold.opacity(0.10),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .scaleEffect(glowScale)
                    .opacity(glowOpacity)
                    .blur(radius: 40)
            )

            // Live stats
            HStack(spacing: 0) {
                hookStat(
                    value: viewModel.connectionsStat,
                    label: "connections\ntonight",
                    icon: "person.2.fill"
                )
                hookStat(
                    value: viewModel.eventsStat,
                    label: "events\nlive now",
                    icon: "sparkles"
                )
                hookStat(
                    value: viewModel.matchesStat,
                    label: "matches\nwaiting",
                    icon: "heart.fill"
                )
            }
            .padding(.horizontal, VennSpacing.xl)
            .padding(.top, 48)
            .opacity(statsVisible ? 1 : 0)
            .offset(y: statsVisible ? 0 : 24)

            Spacer()

            // CTA
            Button {
                ctaTapped.toggle()
                viewModel.advanceToLocation()
            } label: {
                HStack(spacing: 10) {
                    Text("Find your people")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .symbolEffect(.wiggle.forward, value: ctaTapped)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [VennColors.coral, VennColors.gold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: VennColors.coral.opacity(0.45), radius: 20, y: 8)
                )
            }
            .padding(.horizontal, VennSpacing.xl)
            .padding(.bottom, 60)
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 16)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.8)) {
                glowScale = 1.0
                glowOpacity = 1.0
            }
            withAnimation(VennAnimation.gentle.delay(0.4)) {
                titleVisible = true
            }
            withAnimation(VennAnimation.gentle.delay(0.8)) {
                statsVisible = true
            }
            Task { await viewModel.animateHookCounters() }
            withAnimation(VennAnimation.gentle.delay(1.6)) {
                ctaVisible = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(2)) {
                glowScale = 1.15
            }
        }
    }

    private func hookStat(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(VennColors.coral.opacity(0.7))
                .symbolEffect(.pulse.byLayer)

            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: false))
                .animation(.spring(.bouncy), value: value)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(VennColors.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Phase 2: Location (Waymo-style coverage map)

private struct LocationPhaseView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @StateObject private var locationManager = LocationManager()

    // Map camera state — starts on Bay Area, animates to user location
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.55, longitude: -122.1),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        )
    )
    @State private var hasAnimatedToUser = false
    @State private var cardVisible = false
    @State private var headerVisible = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6
    @State private var continueTapped = false

    // Service area polygon — Bay Area coverage
    private var serviceAreaPolygon: [CLLocationCoordinate2D] {
        OnboardingViewModel.serviceAreaPolygon
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-screen dark map
            mapLayer

            // Floating glassmorphism header
            if headerVisible {
                VStack(spacing: 0) {
                    locationHeader
                    Spacer()
                }
                .transition(.opacity.combined(with: .offset(y: -10)))
            }

            // Bottom sheet card
            if cardVisible {
                locationBottomCard
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity.combined(with: .move(edge: .bottom))
                    ))
            }
        }
        .ignoresSafeArea()
        .colorScheme(.dark)
        .onAppear {
            withAnimation(VennAnimation.gentle.delay(0.3)) {
                headerVisible = true
            }
            withAnimation(VennAnimation.gentle.delay(0.6)) {
                cardVisible = true
            }
            startPulseAnimation()
        }
        .onChange(of: locationManager.coordinate) { _, newCoordinate in
            guard let newCoordinate else { return }
            viewModel.checkLocation(coordinate: newCoordinate)
            if !hasAnimatedToUser {
                hasAnimatedToUser = true
                withAnimation(.easeInOut(duration: 1.4)) {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: newCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
                    ))
                }
                HapticManager.shared.impact(.light)
            }
        }
        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
            if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                locationManager.startLocating()
            }
        }
    }

    // MARK: Map Layer

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            // Service area polygon fill — coral glow overlay
            MapPolygon(coordinates: serviceAreaPolygon)
                .foregroundStyle(VennColors.coral.opacity(0.15))
                .stroke(VennColors.coral.opacity(0.5), lineWidth: 2)

            // Waitlist heatmap dots — glowing annotations at cities
            ForEach(OnboardingViewModel.waitlistHotspots) { hotspot in
                Annotation("", coordinate: hotspot.coordinate) {
                    WaitlistHeatDot(hotspot: hotspot)
                }
            }

            // User's newly added heatmap dot (after joining waitlist)
            if let userDot = viewModel.userHotspot {
                Annotation("", coordinate: userDot.coordinate) {
                    WaitlistHeatDot(hotspot: userDot, isUserDot: true)
                }
            }

            // User location annotation — pulsing dot
            if let coordinate = locationManager.coordinate {
                Annotation("", coordinate: coordinate) {
                    ZStack {
                        // Outer pulse ring
                        Circle()
                            .fill(
                                viewModel.locationChecked
                                ? (viewModel.isInServiceArea
                                   ? VennColors.coral.opacity(0.25)
                                   : Color.white.opacity(0.12))
                                : VennColors.coral.opacity(0.20)
                            )
                            .frame(width: 44, height: 44)
                            .scaleEffect(pulseScale)
                            .opacity(pulseOpacity)

                        // Inner dot
                        Circle()
                            .fill(
                                viewModel.locationChecked && !viewModel.isInServiceArea
                                ? Color.white.opacity(0.55)
                                : VennColors.coral
                            )
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(
                                color: viewModel.isInServiceArea
                                    ? VennColors.coral.opacity(0.6)
                                    : Color.black.opacity(0.3),
                                radius: 6
                            )
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll))
        .ignoresSafeArea()
    }

    // MARK: Floating Header

    private var locationHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Where are you?")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Finding events near you")
                    .font(VennTypography.caption)
                    .foregroundColor(VennColors.textSecondary)
            }

            Spacer()

            // Live demand counter
            HStack(spacing: 6) {
                Circle()
                    .fill(VennColors.coral)
                    .frame(width: 6, height: 6)
                    .modifier(PulseGlow())
                Text("\(OnboardingViewModel.totalWaitlistCount.formatted()) waiting")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.coral)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(VennColors.coral.opacity(0.12))
                    .overlay(
                        Capsule()
                            .stroke(VennColors.coral.opacity(0.2), lineWidth: 1)
                    )
            )

            // Vivi orb
            ViviOrb(size: 32)
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.vertical, VennSpacing.md)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(VennColors.borderSubtle)
                .frame(height: 1),
            alignment: .bottom
        )
        .padding(.top, 56) // safe area top
    }

    // MARK: Bottom Card — switches based on state

    @ViewBuilder
    private var locationBottomCard: some View {
        if locationManager.authorizationStatus == .notDetermined ||
           locationManager.authorizationStatus == .denied ||
           locationManager.authorizationStatus == .restricted {
            // No permission yet
            locationPermissionCard
        } else if let coordinate = locationManager.coordinate, viewModel.locationChecked {
            if viewModel.isInServiceArea {
                inServiceAreaCard(coordinate: coordinate)
            } else {
                outOfServiceAreaCard
            }
        } else {
            // Permission granted but still locating
            locatingCard
        }
    }

    // Permission request card
    private var locationPermissionCard: some View {
        GlassBottomCard {
            VStack(spacing: VennSpacing.xl) {
                VStack(spacing: VennSpacing.sm) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [VennColors.coral, VennColors.gold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Enable location to find events near you")
                        .font(VennTypography.heading)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Venn shows you what's happening in your neighborhood tonight.")
                        .font(VennTypography.body)
                        .foregroundColor(VennColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    HapticManager.shared.impact(.medium)
                    locationManager.requestPermission()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Allow Location")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [VennColors.coral, VennColors.gold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: VennColors.coral.opacity(0.45), radius: 20, y: 8)
                    )
                }

                Button {
                    HapticManager.shared.impact(.light)
                    viewModel.advanceToConversation()
                } label: {
                    Text("Enter manually")
                        .font(VennTypography.captionBold)
                        .foregroundColor(VennColors.textTertiary)
                }
            }
        }
    }

    // Locating spinner card — with timeout fallback
    private var locatingCard: some View {
        GlassBottomCard {
            VStack(spacing: VennSpacing.lg) {
                HStack(spacing: VennSpacing.md) {
                    if locationManager.locationFailed {
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(VennColors.textTertiary)
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(VennColors.coral)
                    }
                    Text(locationManager.locationFailed ? "Couldn't get your location" : "Finding your location...")
                        .font(VennTypography.bodyLarge)
                        .foregroundColor(VennColors.textSecondary)
                }

                if locationManager.locationFailed {
                    Button {
                        HapticManager.shared.impact(.light)
                        viewModel.advanceToConversation()
                    } label: {
                        Text("Continue without location")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.10))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            )
                    }

                    Button {
                        HapticManager.shared.impact(.light)
                        locationManager.startLocating()
                    } label: {
                        Text("Try again")
                            .font(VennTypography.captionBold)
                            .foregroundColor(VennColors.coral)
                    }
                }
            }
            .padding(.vertical, locationManager.locationFailed ? 0 : VennSpacing.md)
        }
    }

    // In-service-area success card
    private func inServiceAreaCard(coordinate: CLLocationCoordinate2D) -> some View {
        GlassBottomCard {
            VStack(spacing: VennSpacing.xl) {
                VStack(spacing: VennSpacing.sm) {
                    HStack(spacing: VennSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(VennColors.coral.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(VennColors.coral)
                                .symbolEffect(.bounce, value: viewModel.locationChecked)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("You're in")
                                .font(VennTypography.captionBold)
                                .foregroundColor(VennColors.coral)
                                .textCase(.uppercase)
                                .tracking(1)
                            Text(viewModel.detectedCity.isEmpty ? "the Bay Area" : viewModel.detectedCity)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }

                    Text("Join \(viewModel.similarPeopleCount > 0 ? viewModel.similarPeopleCount : 340) people already exploring events near you.")
                        .font(VennTypography.body)
                        .foregroundColor(VennColors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    HapticManager.shared.impact(.medium)
                    continueTapped.toggle()
                    viewModel.advanceToConversation()
                } label: {
                    HStack(spacing: 10) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                            .symbolEffect(.wiggle.forward, value: continueTapped)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [VennColors.coral, VennColors.gold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: VennColors.coral.opacity(0.45), radius: 20, y: 8)
                    )
                }
            }
        }
    }

    // Out-of-service-area waitlist card
    private var outOfServiceAreaCard: some View {
        GlassBottomCard {
            VStack(spacing: VennSpacing.xl) {
                VStack(spacing: VennSpacing.sm) {
                    HStack(spacing: VennSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 40, height: 40)
                            Image(systemName: "map.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(VennColors.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("We're not in \(viewModel.detectedCity.isEmpty ? "your city" : viewModel.detectedCity) yet")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("But we're expanding fast")
                                .font(VennTypography.caption)
                                .foregroundColor(VennColors.textTertiary)
                        }

                        Spacer()
                    }

                    HStack(spacing: VennSpacing.xs) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(VennColors.coral.opacity(0.7))
                        Text("\(viewModel.waitlistCount) people are waiting in \(viewModel.detectedCity.isEmpty ? "your area" : viewModel.detectedCity)")
                            .font(VennTypography.captionBold)
                            .foregroundColor(VennColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Email field
                TextField("your@email.com", text: $viewModel.waitlistEmail)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, VennSpacing.lg)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            )
                    )

                if viewModel.joinedWaitlist {
                    HStack(spacing: VennSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(VennColors.coral)
                        Text("You're on the list! We'll notify you.")
                            .font(VennTypography.body)
                            .foregroundColor(VennColors.textSecondary)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    Button {
                        HapticManager.shared.impact(.medium)
                        viewModel.joinWaitlist(userCoordinate: locationManager.coordinate)
                    } label: {
                        Text("Notify Me")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [VennColors.coral, VennColors.gold],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: VennColors.coral.opacity(0.45), radius: 20, y: 8)
                            )
                    }
                    .disabled(viewModel.waitlistEmail.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(viewModel.waitlistEmail.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                }

                Button {
                    HapticManager.shared.impact(.light)
                    viewModel.advanceToConversation()
                } label: {
                    Text("Skip for now")
                        .font(VennTypography.captionBold)
                        .foregroundColor(VennColors.textTertiary)
                }
            }
        }
    }

    // MARK: Pulse Animation

    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.6)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 2.0
            pulseOpacity = 0.0
        }
    }
}

// MARK: - Glass Bottom Card Container

private struct GlassBottomCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.horizontal, VennSpacing.xl)
                .padding(.top, VennSpacing.xxl)
                .padding(.bottom, 40) // extra for home indicator
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 32, y: -8)
        )
    }
}

// MARK: - Pulse Glow Modifier

private struct PulseGlow: ViewModifier {
    @State private var active = false

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .fill(VennColors.coral.opacity(0.6))
                    .scaleEffect(active ? 2.5 : 1.0)
                    .opacity(active ? 0 : 0.8)
            )
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    active = true
                }
            }
    }
}

// MARK: - Waitlist Heatmap Dot

private struct WaitlistHeatDot: View {
    let hotspot: OnboardingViewModel.WaitlistHotspot
    var isUserDot: Bool = false
    @State private var glowPhase: Bool = false
    @State private var appeared: Bool = false

    /// Dot diameter scales with intensity: 10pt (low) → 28pt (high)
    private var dotSize: CGFloat {
        isUserDot ? 16 : 10 + 18 * hotspot.intensity
    }

    /// Outer glow ring
    private var glowSize: CGFloat {
        dotSize * (isUserDot ? 3.5 : 2.5)
    }

    var body: some View {
        ZStack {
            // Radial glow — breathes slowly
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            VennColors.coral.opacity(isUserDot ? 0.5 : 0.35 * hotspot.intensity),
                            VennColors.coral.opacity(isUserDot ? 0.15 : 0.08 * hotspot.intensity),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: glowSize / 2
                    )
                )
                .frame(width: glowSize, height: glowSize)
                .scaleEffect(glowPhase ? 1.15 : 0.9)
                .opacity(glowPhase ? 1 : 0.7)

            // Core dot
            Circle()
                .fill(
                    LinearGradient(
                        colors: isUserDot
                            ? [Color.white, VennColors.coral]
                            : [VennColors.coral, VennColors.gold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: dotSize, height: dotSize)
                .shadow(color: VennColors.coral.opacity(0.6), radius: dotSize * 0.4)

            // User dot gets a ring highlight
            if isUserDot {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: dotSize + 4, height: dotSize + 4)
            }

            // Count label — only show for larger dots
            if hotspot.count >= 200 && !isUserDot {
                Text("\(hotspot.count)")
                    .font(.system(size: 8, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2)
            }
        }
        .scaleEffect(appeared ? 1 : 0.01)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(isUserDot ? VennAnimation.bouncy : .easeOut(duration: 0.5).delay(Double.random(in: 0...0.8))) {
                appeared = true
            }
            withAnimation(
                .easeInOut(duration: Double.random(in: 2.0...3.5))
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...1.5))
            ) {
                glowPhase = true
            }
        }
    }
}

// MARK: - Phase 3: AI Conversation

private struct ConversationPhaseView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var headerVisible = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            conversationHeader
                .opacity(headerVisible ? 1 : 0)

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.insightCards) { card in
                            InsightCardBubble(card: card)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .offset(y: 20)),
                                    removal: .opacity
                                ))
                                .scrollTransition(.animated(.bouncy)) { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.5)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.92)
                                        .offset(y: phase.isIdentity ? 0 : phase.value * 15)
                                }
                        }

                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .offset(y: 12)),
                                    removal: .opacity
                                ))
                                .scrollTransition(.animated(.bouncy)) { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.5)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.92)
                                        .offset(y: phase.isIdentity ? 0 : phase.value * 15)
                                }
                        }

                        if viewModel.isViviTyping {
                            ViviTypingIndicator()
                                .id("typing")
                                .transition(.opacity.combined(with: .offset(y: 8)))
                        }
                    }
                    .padding(.horizontal, VennSpacing.lg)
                    .padding(.vertical, VennSpacing.md)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation(VennAnimation.standard) {
                        if let last = viewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isViviTyping) { _, newTyping in
                    if newTyping {
                        withAnimation(VennAnimation.standard) {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }

            if !viewModel.quickReplies.isEmpty {
                quickReplySection
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            inputBar
        }
        .onAppear {
            withAnimation(VennAnimation.gentle.delay(0.2)) {
                headerVisible = true
            }
        }
    }

    // MARK: Header

    private var conversationHeader: some View {
        HStack {
            Button {
                Task { await viewModel.skipConversation() }
            } label: {
                Text("Skip")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(VennColors.textTertiary)
            }

            Spacer()

            HStack(spacing: 6) {
                ViviOrb(size: 24)
                Text("Vivi")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Image(systemName: "waveform")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(VennColors.coral.opacity(0.7))
                    .symbolEffect(.breathe)
            }

            Spacer()

            UnderstandingRing(progress: viewModel.understandingProgress)
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.vertical, VennSpacing.md)
    }

    // MARK: Quick Replies

    private var quickReplySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.quickReplies, id: \.self) { reply in
                    Button {
                        Task { await viewModel.sendMessage(reply) }
                    } label: {
                        Text(reply)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(VennColors.coral)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(VennColors.coral.opacity(0.12))
                                    .overlay(
                                        Capsule()
                                            .stroke(VennColors.coral.opacity(0.25), lineWidth: 1)
                                    )
                            )
                    }
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
            }
            .padding(.horizontal, VennSpacing.lg)
            .padding(.vertical, VennSpacing.sm)
        }
        .animation(VennAnimation.standard, value: viewModel.quickReplies)
    }

    // MARK: Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Type a message...", text: $viewModel.userInput)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .focused($inputFocused)
                .onSubmit {
                    let text = viewModel.userInput
                    Task { await viewModel.sendMessage(text) }
                }

            Button {
                let text = viewModel.userInput
                Task { await viewModel.sendMessage(text) }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color.white.opacity(0.2)
                        : VennColors.coral
                    )
            }
            .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, VennSpacing.lg)
        .padding(.vertical, VennSpacing.sm)
        .padding(.bottom, VennSpacing.xs)
    }
}

// MARK: - Reveal Keyframes

private struct RevealKeyframes {
    var scale: Double = 1.0
    var rotation: Double = 0.0
    var opacity: Double = 1.0
}

// MARK: - Phase 4: The Reveal

private struct RevealPhaseView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var confettiVisible = false
    @State private var revealCtaTapped = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if viewModel.revealVisible {
                // SF Symbol icon circle — no emojis
                KeyframeAnimator(
                    initialValue: RevealKeyframes(),
                    trigger: viewModel.revealVisible
                ) { value in
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [VennColors.coral, VennColors.gold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: VennColors.coral.opacity(0.4), radius: 24, y: 8)
                        Image(systemName: viewModel.personalityIcon)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .symbolEffect(.bounce.up.byLayer, value: viewModel.revealVisible)
                    }
                    .scaleEffect(value.scale)
                    .rotationEffect(.degrees(value.rotation))
                    .opacity(value.opacity)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        SpringKeyframe(0.5, duration: 0.2, spring: .snappy)
                        SpringKeyframe(1.15, duration: 0.4, spring: .bouncy)
                        SpringKeyframe(1.0, duration: 0.3, spring: .smooth)
                    }
                    KeyframeTrack(\.rotation) {
                        LinearKeyframe(0, duration: 0.1)
                        SpringKeyframe(-8, duration: 0.15, spring: .snappy)
                        SpringKeyframe(5, duration: 0.15, spring: .snappy)
                        SpringKeyframe(0, duration: 0.2, spring: .smooth)
                    }
                    KeyframeTrack(\.opacity) {
                        LinearKeyframe(0, duration: 0.05)
                        LinearKeyframe(1, duration: 0.3)
                    }
                }
                .transition(.scale(scale: 0).combined(with: .opacity))
                .padding(.bottom, VennSpacing.lg)

                // Personality type
                Text(viewModel.personalityType)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [VennColors.coral, VennColors.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .transition(.opacity.combined(with: .offset(y: 16)))
                    .padding(.bottom, VennSpacing.sm)

                // Summary
                Text(viewModel.personalitySummary)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .offset(y: 12)))

                // Stats
                HStack(spacing: 32) {
                    revealStat(
                        value: "\(viewModel.recommendedEventsCount)",
                        label: "events for you",
                        icon: "calendar.badge.checkmark"
                    )
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1, height: 48)
                    revealStat(
                        value: "\(viewModel.similarPeopleCount)",
                        label: "similar people",
                        icon: "person.2.fill"
                    )
                }
                .padding(.top, 36)
                .transition(.opacity.combined(with: .offset(y: 12)))

                // Vivi message
                HStack(spacing: 8) {
                    ViviOrb(size: 20)
                    Text("I know exactly what to look for.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(VennColors.textSecondary)
                        .italic()
                }
                .padding(.top, 28)
                .transition(.opacity)
            }

            Spacer()

            // CTA
            if viewModel.revealVisible {
                Button {
                    revealCtaTapped.toggle()
                    Task { await viewModel.finishOnboarding() }
                } label: {
                    HStack(spacing: 10) {
                        Text("Start Exploring")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                            .symbolEffect(.wiggle.forward, value: revealCtaTapped)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [VennColors.coral, VennColors.gold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: VennColors.coral.opacity(0.5), radius: 24, y: 8)
                    )
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.bottom, 60)
                .transition(.opacity.combined(with: .offset(y: 20)))
            }
        }
        .overlay {
            if confettiVisible {
                PremiumConfetti()
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: viewModel.revealVisible) { _, newVisible in
            if newVisible {
                withAnimation(VennAnimation.bouncy.delay(0.4)) {
                    confettiVisible = true
                }
            }
        }
    }

    private func revealStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(VennColors.coral.opacity(0.7))
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(VennColors.textTertiary)
        }
    }
}

// MARK: - Supporting Views

// MARK: Vivi Orb

private struct ViviOrb: View {
    let size: CGFloat
    @State private var animating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(VennColors.coral.opacity(0.5))
                .frame(width: size, height: size)
                .offset(x: -size * 0.08)
                .blur(radius: size * 0.1)
            Circle()
                .fill(VennColors.gold.opacity(0.4))
                .frame(width: size * 0.85, height: size * 0.85)
                .offset(x: size * 0.1)
                .blur(radius: size * 0.08)
            Circle()
                .fill(VennColors.indigo.opacity(0.3))
                .frame(width: size * 0.7, height: size * 0.7)
                .offset(y: size * 0.06)
                .blur(radius: size * 0.06)
        }
        .compositingGroup()
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [VennColors.coral.opacity(0.4), VennColors.gold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(animating ? 1.06 : 1.0)
        .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: animating)
        .onAppear { animating = true }
    }
}

// MARK: Chat Bubble

private struct ChatBubble: View {
    let message: OnboardingViewModel.ChatMessage
    @State private var appeared = false

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            if !message.isUser {
                ViviOrb(size: 28)
                    .padding(.trailing, 4)
            }

            Text(message.content)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(message.isUser ? .white : VennColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            message.isUser
                            ? LinearGradient(
                                colors: [VennColors.coral, VennColors.coral.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(
                                    message.isUser
                                    ? Color.clear
                                    : Color.white.opacity(0.06),
                                    lineWidth: 1
                                )
                        )
                )

            if !message.isUser { Spacer(minLength: 40) }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(VennAnimation.standard.delay(0.05)) {
                appeared = true
            }
        }
    }
}

// MARK: Typing Indicator

private struct ViviTypingIndicator: View {
    var body: some View {
        HStack {
            ViviOrb(size: 28)
                .padding(.trailing, 4)

            PhaseAnimator([false, true]) { phase in
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(VennColors.coral.opacity(phase ? 0.9 : 0.3))
                            .frame(width: 8, height: 8)
                            .offset(y: phase ? -6 : 0)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.5)
                                    .delay(Double(i) * 0.15),
                                value: phase
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
            } animation: { phase in
                .easeInOut(duration: 0.45)
            }

            Spacer()
        }
    }
}

// MARK: Insight Card

private struct InsightCardBubble: View {
    let card: OnboardingViewModel.InsightCard
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(card.accent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: card.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(card.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(card.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(card.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(VennColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(card.accent.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: card.accent.opacity(0.15), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.08), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: shimmerOffset)
                .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.2)) {
                shimmerOffset = 400
            }
        }
    }
}

// MARK: Understanding Ring

private struct UnderstandingRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 3)
                .frame(width: 32, height: 32)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [VennColors.coral, VennColors.gold, VennColors.coral],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(-90))
                .animation(VennAnimation.standard, value: progress)

            Text("\(Int(progress * 100))")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(VennColors.textSecondary)
        }
    }
}

// MARK: - Premium Confetti Particle System

private struct PremiumConfetti: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var timer: Timer?

    // Particle model
    struct ConfettiParticle: Identifiable {
        let id = UUID()

        // Appearance
        let color: Color
        let shape: ParticleShape
        let size: CGFloat
        let depth: CGFloat       // 0 = far, 1 = near — affects size + opacity

        // Physics state
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var opacity: Double

        // Physics constants
        let velocityX: CGFloat
        let velocityY: CGFloat   // initial upward burst (negative = up)
        let gravity: CGFloat
        let drag: CGFloat
        let rotationSpeed: Double
        let driftX: CGFloat      // subtle horizontal sinusoidal drift amplitude

        // Phase tracking
        var age: Double          // seconds since birth
        let lifetime: Double
    }

    enum ParticleShape: CaseIterable {
        case circle, rectangle, thinLine, diamond
    }

    // Design palette — premium metallic tones
    private let palette: [Color] = [
        VennColors.coral,
        VennColors.gold,
        VennColors.indigo,
        Color.white,
        Color(red: 1.0, green: 0.85, blue: 0.55),   // warm gold metallic
        Color(red: 0.85, green: 0.75, blue: 1.0),   // soft lavender metallic
        Color(red: 1.0, green: 0.45, blue: 0.38),   // bright coral pop
        Color(red: 0.55, green: 0.90, blue: 0.85),  // teal shimmer
    ]

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let cx = size.width / 2
                    let cy = size.height * 0.38

                    for particle in particles {
                        let elapsed = particle.age
                        guard elapsed < particle.lifetime else { continue }

                        // Physics integration
                        let t = elapsed
                        let drag = pow(particle.drag, t)
                        let px = cx + (particle.velocityX * t * drag)
                            + sin(t * 1.8 + particle.driftX) * particle.driftX * t
                        let py = cy
                            + (particle.velocityY * t * drag)
                            + 0.5 * particle.gravity * t * t

                        let currentRotation = particle.rotation + particle.rotationSpeed * t

                        // Fade: burst phase stays opaque, gravity phase fades
                        let fadeStart = particle.lifetime * 0.55
                        let fadeAlpha: Double
                        if elapsed < fadeStart {
                            fadeAlpha = 1.0
                        } else {
                            fadeAlpha = max(0, 1.0 - (elapsed - fadeStart) / (particle.lifetime - fadeStart))
                        }
                        let alpha = particle.opacity * fadeAlpha

                        // Depth-of-field size modulation
                        let depthScale = 0.6 + particle.depth * 0.7

                        var contextCopy = context
                        contextCopy.opacity = alpha
                        contextCopy.translateBy(x: px, y: py)
                        contextCopy.rotate(by: .degrees(currentRotation))

                        let w = particle.size * depthScale
                        let h: CGFloat

                        switch particle.shape {
                        case .circle:
                            h = w
                            let rect = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)
                            contextCopy.fill(Ellipse().path(in: rect), with: .color(particle.color))

                        case .rectangle:
                            h = w * CGFloat.random(in: 0.45...0.75)
                            let rect = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)
                            contextCopy.fill(Rectangle().path(in: rect), with: .color(particle.color))

                        case .thinLine:
                            h = w * 0.18
                            let rect = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)
                            contextCopy.fill(Rectangle().path(in: rect), with: .color(particle.color))

                        case .diamond:
                            h = w * 1.2
                            var path = Path()
                            path.move(to: CGPoint(x: 0, y: -h / 2))
                            path.addLine(to: CGPoint(x: w / 2, y: 0))
                            path.addLine(to: CGPoint(x: 0, y: h / 2))
                            path.addLine(to: CGPoint(x: -w / 2, y: 0))
                            path.closeSubpath()
                            contextCopy.fill(path, with: .color(particle.color))
                        }
                    }
                }
            }
            .onAppear {
                spawnParticles(in: geo.size)
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
    }

    private func spawnParticles(in size: CGSize) {
        var newParticles: [ConfettiParticle] = []
        let count = 90

        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 180...520)
            let depth = CGFloat.random(in: 0...1)
            let lifetime = Double.random(in: 2.2...3.4)
            let shape = ParticleShape.allCases.randomElement()!

            // Larger near particles, smaller far particles
            let baseSize = CGFloat.random(in: 5...13) * (0.5 + depth * 0.8)

            newParticles.append(ConfettiParticle(
                color: palette.randomElement()!,
                shape: shape,
                size: baseSize,
                depth: depth,
                x: 0,
                y: 0,
                rotation: Double.random(in: 0...360),
                opacity: 0.7 + depth * 0.3,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed - CGFloat.random(in: 80...200), // upward bias
                gravity: CGFloat.random(in: 220...340),
                drag: CGFloat.random(in: 0.88...0.96),
                rotationSpeed: Double.random(in: -400...400),
                driftX: CGFloat.random(in: -20...20),
                age: 0,
                lifetime: lifetime
            ))
        }
        particles = newParticles
    }

    private func startTimer() {
        var lastTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            let now = Date()
            let dt = now.timeIntervalSince(lastTime)
            lastTime = now

            var allDead = true
            for i in particles.indices {
                particles[i].age += dt
                if particles[i].age < particles[i].lifetime {
                    allDead = false
                }
            }

            if allDead {
                timer?.invalidate()
                timer = nil
                particles.removeAll()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingFlowView()
        .environmentObject(AuthenticationManager.shared)
}
