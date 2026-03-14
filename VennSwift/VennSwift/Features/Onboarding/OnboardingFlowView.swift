import SwiftUI

// MARK: - Confetti Particle

private struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let angle: Double
    let distance: CGFloat
    let rotation: Double
    let delay: Double
}

// MARK: - OnboardingFlowView

struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var currentStep = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var appeared = false

    // Background orbs
    @State private var orbDrift = false
    @State private var glowPulse = false

    // Confetti
    @State private var showConfetti = false

    // Next button press state
    @State private var nextPressed = false

    private let totalSteps = 5

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            backgroundLayer

            if showConfetti {
                OnboardingConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            VStack(spacing: 0) {
                progressBar
                    .padding(.top, VennSpacing.massive + VennSpacing.sm)
                    .padding(.horizontal, VennSpacing.xxl)

                swipeableContent

                navigationButtons
                    .padding(.horizontal, VennSpacing.xxl)
                    .padding(.bottom, VennSpacing.massive)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(VennAnimation.gentle.delay(0.2)) { appeared = true }
            startBackgroundAnimations()
        }
        .onChange(of: currentStep) { _ in
            if currentStep == totalSteps - 1 {
                withAnimation(VennAnimation.bouncy) { showConfetti = true }
                Task { @MainActor in HapticManager.shared.success() }
            } else {
                showConfetti = false
            }
        }
    }

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        ZStack {
            Circle()
                .fill(stepAccentColor.opacity(0.07))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: orbDrift ? -90 : 90, y: orbDrift ? -140 : -50)

            Circle()
                .fill(VennColors.gold.opacity(0.05))
                .frame(width: 170, height: 170)
                .blur(radius: 55)
                .offset(x: orbDrift ? 110 : -60, y: orbDrift ? 90 : 210)

            Circle()
                .fill(VennColors.indigo.opacity(0.04))
                .frame(width: 130, height: 130)
                .blur(radius: 45)
                .offset(x: orbDrift ? -70 : 50, y: orbDrift ? 310 : 110)

            Circle()
                .fill(stepAccentColor.opacity(glowPulse ? 0.10 : 0.04))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(y: -80)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.0), value: currentStep)
    }

    private var stepAccentColor: Color {
        switch currentStep {
        case 0: return VennColors.coral
        case 1: return VennColors.gold
        case 2: return VennColors.indigo
        case 3: return VennColors.coral
        default: return VennColors.gold
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: VennSpacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep
                          ? AnyShapeStyle(LinearGradient(colors: [VennColors.coral, VennColors.gold],
                                                         startPoint: .leading, endPoint: .trailing))
                          : AnyShapeStyle(VennColors.borderMedium))
                    .frame(height: 3)
                    .animation(VennAnimation.standard, value: currentStep)
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - Swipeable Content

    private var swipeableContent: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Step1SocialEnergyView(viewModel: viewModel)
                    .frame(width: geo.size.width)
                Step2PerfectNightView(viewModel: viewModel)
                    .frame(width: geo.size.width)
                Step3InterestsView(viewModel: viewModel)
                    .frame(width: geo.size.width)
                Step4SocialStyleView(viewModel: viewModel)
                    .frame(width: geo.size.width)
                Step5CompleteView(viewModel: viewModel, authManager: authManager)
                    .frame(width: geo.size.width)
            }
            .offset(x: -CGFloat(currentStep) * geo.size.width + dragOffset)
            .animation(isDragging ? nil : VennAnimation.standard, value: currentStep)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        isDragging = true
                        let raw = value.translation.width
                        let atEdge = (currentStep == 0 && raw > 0) ||
                                     (currentStep == totalSteps - 1 && raw < 0)
                        dragOffset = atEdge ? raw * 0.15 : raw
                    }
                    .onEnded { value in
                        isDragging = false
                        let threshold = geo.size.width * 0.25
                        let velocity = value.predictedEndTranslation.width - value.translation.width
                        let net = value.translation.width + velocity * 0.5
                        withAnimation(VennAnimation.standard) {
                            if net < -threshold && currentStep < totalSteps - 1 && viewModel.isStepValid(currentStep) {
                                currentStep += 1
                                Task { @MainActor in HapticManager.shared.selectionFeedback() }
                            } else if net > threshold && currentStep > 0 {
                                currentStep -= 1
                                Task { @MainActor in HapticManager.shared.selectionFeedback() }
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: VennSpacing.lg) {
            if currentStep > 0 && currentStep < totalSteps - 1 {
                Button {
                    withAnimation(VennAnimation.standard) { currentStep -= 1 }
                    Task { @MainActor in HapticManager.shared.selectionFeedback() }
                } label: {
                    HStack(spacing: VennSpacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(VennTypography.buttonLabel)
                    }
                    .foregroundColor(VennColors.textSecondary)
                    .frame(height: 56)
                    .padding(.horizontal, VennSpacing.xl)
                    .background(
                        Capsule()
                            .fill(VennColors.glassLight)
                            .overlay(Capsule().stroke(VennColors.borderMedium, lineWidth: 1))
                    )
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }

            if currentStep < totalSteps - 1 {
                let valid = viewModel.isStepValid(currentStep)
                Button {
                    guard valid else {
                        Task { @MainActor in HapticManager.shared.impact(.light) }
                        return
                    }
                    withAnimation(VennAnimation.standard) { currentStep += 1 }
                    Task { @MainActor in HapticManager.shared.selectionFeedback() }
                } label: {
                    HStack(spacing: VennSpacing.sm) {
                        Text("Continue")
                            .font(VennTypography.buttonLabel)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Capsule()
                            .fill(valid
                                  ? AnyShapeStyle(LinearGradient(colors: [VennColors.coral, VennColors.gold],
                                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                                  : AnyShapeStyle(VennColors.surfaceSecondary))
                            .shadow(color: valid ? VennColors.coral.opacity(0.35) : .clear,
                                    radius: 16, y: 6)
                    )
                    .animation(VennAnimation.micro, value: valid)
                }
            }
        }
        .animation(VennAnimation.standard, value: currentStep)
    }

    // MARK: - Animation Helpers

    private func startBackgroundAnimations() {
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) { orbDrift = true }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { glowPulse = true }
    }
}

// MARK: - Step Header

private struct StepHeader: View {
    let title: String
    let subtitle: String
    @State private var titleVisible = false
    @State private var subtitleVisible = false

    var body: some View {
        VStack(spacing: VennSpacing.sm) {
            Text(title)
                .font(VennTypography.heading)
                .foregroundColor(VennColors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : 12)

            Text(subtitle)
                .font(VennTypography.bodyLarge)
                .foregroundColor(VennColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, VennSpacing.md)
                .opacity(subtitleVisible ? 1 : 0)
                .offset(y: subtitleVisible ? 0 : 8)
        }
        .onAppear {
            withAnimation(VennAnimation.gentle.delay(0.1)) { titleVisible = true }
            withAnimation(VennAnimation.gentle.delay(0.3)) { subtitleVisible = true }
        }
    }
}

// MARK: - Step 1: Social Energy

private struct Step1SocialEnergyView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var sliderAppeared = false
    @State private var batteryAppeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: VennSpacing.xxxl) {
                StepHeader(
                    title: "Your Social Energy",
                    subtitle: "How do you recharge and what's your crowd comfort zone?"
                )
                .padding(.top, VennSpacing.xl)

                energySlider
                    .opacity(sliderAppeared ? 1 : 0)
                    .offset(y: sliderAppeared ? 0 : 20)

                batterySection
                    .opacity(batteryAppeared ? 1 : 0)
                    .offset(y: batteryAppeared ? 0 : 20)
            }
            .padding(.horizontal, VennSpacing.xxl)
            .padding(.bottom, VennSpacing.xxxl)
        }
        .onAppear {
            withAnimation(VennAnimation.standard.delay(0.4)) { sliderAppeared = true }
            withAnimation(VennAnimation.standard.delay(0.6)) { batteryAppeared = true }
        }
    }

    // Custom pill slider
    private var energySlider: some View {
        VStack(spacing: VennSpacing.lg) {
            Text("Social Spectrum")
                .font(VennTypography.bodyMedium)
                .foregroundColor(VennColors.textSecondary)

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(VennColors.surfaceSecondary)
                    .frame(height: 28)

                // Filled track — coral to gold gradient
                GeometryReader { geo in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [VennColors.coral, VennColors.gold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(28, geo.size.width * viewModel.introExtrovert), height: 28)
                        .animation(VennAnimation.micro, value: viewModel.introExtrovert)

                    // Draggable thumb
                    Circle()
                        .fill(.white)
                        .frame(width: 34, height: 34)
                        .shadow(color: VennColors.coral.opacity(0.5), radius: 8, y: 2)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(colors: [VennColors.coral, VennColors.gold],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 2
                                )
                        )
                        .glow(color: VennColors.coral, radius: 10, intensity: 0.4)
                        .offset(
                            x: max(0, min(
                                geo.size.width - 34,
                                geo.size.width * viewModel.introExtrovert - 17
                            )),
                            y: -3
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let newVal = value.location.x / geo.size.width
                                    viewModel.introExtrovert = max(0, min(1, newVal))
                                    Task { @MainActor in HapticManager.shared.impact(.soft) }
                                }
                        )
                        .animation(nil, value: viewModel.introExtrovert)
                }
                .frame(height: 28)
            }
            .frame(height: 34)

            // Emoji endpoints
            HStack {
                VStack(spacing: 2) {
                    Text("🌙")
                        .font(.system(size: 22))
                    Text("Quiet night")
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textTertiary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("🎉")
                        .font(.system(size: 22))
                    Text("Party mode")
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textTertiary)
                }
            }
        }
        .padding(VennSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: VennRadius.xl, style: .continuous)
                .fill(VennColors.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: VennRadius.xl, style: .continuous)
                        .stroke(VennColors.borderSubtle, lineWidth: 1)
                )
        )
    }

    // Social battery cards
    private var batterySection: some View {
        VStack(alignment: .leading, spacing: VennSpacing.lg) {
            Text("Social Battery")
                .font(VennTypography.bodyMedium)
                .foregroundColor(VennColors.textSecondary)

            HStack(spacing: VennSpacing.md) {
                ForEach(SocialBattery.allCases) { battery in
                    BatteryCard(
                        battery: battery,
                        isSelected: viewModel.socialBattery == battery
                    ) {
                        withAnimation(VennAnimation.snappy) {
                            viewModel.socialBattery = battery
                        }
                        Task { @MainActor in HapticManager.shared.selectionFeedback() }
                    }
                }
            }
        }
    }
}

private struct BatteryCard: View {
    let battery: SocialBattery
    let isSelected: Bool
    let action: () -> Void

    private var fillCount: Int {
        switch battery {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        }
    }
    private var glowColor: Color {
        switch battery {
        case .low: return VennColors.textTertiary
        case .medium: return VennColors.gold
        case .high: return VennColors.coral
        }
    }
    private var pulseSpeed: Double {
        switch battery {
        case .low: return 3.0
        case .medium: return 2.0
        case .high: return 1.2
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: VennSpacing.sm) {
                // Battery icon with fill bars
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(isSelected ? glowColor : VennColors.borderMedium, lineWidth: 2)
                        .frame(width: 28, height: 48)

                    // Battery cap
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isSelected ? glowColor : VennColors.borderMedium)
                        .frame(width: 10, height: 4)
                        .offset(y: -26)

                    VStack(spacing: 2) {
                        ForEach(0..<3) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i < fillCount ? glowColor : VennColors.surfaceSecondary)
                                .frame(width: 18, height: 10)
                        }
                    }
                }
                .shadow(color: isSelected ? glowColor.opacity(0.6) : .clear, radius: 8)
                .pulse(from: 1.0, to: isSelected ? 1.05 : 1.0, duration: pulseSpeed)

                Text(battery.rawValue)
                    .font(VennTypography.captionBold)
                    .foregroundColor(isSelected ? VennColors.textPrimary : VennColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, VennSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                    .fill(isSelected
                          ? glowColor.opacity(0.12)
                          : VennColors.surfacePrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                            .stroke(isSelected ? glowColor.opacity(0.5) : VennColors.borderSubtle, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(VennAnimation.snappy, value: isSelected)
    }
}

// MARK: - Step 2: Perfect Night

private struct Step2PerfectNightView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var cardsAppeared = false

    private let vibes: [NightVibe] = [
        .intimateDinner, .danceFloor, .adventure, .networking
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: VennSpacing.xxxl) {
                StepHeader(
                    title: "Your Perfect Night",
                    subtitle: "What kind of experience are you chasing?"
                )
                .padding(.top, VennSpacing.xl)

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: VennSpacing.md),
                              GridItem(.flexible(), spacing: VennSpacing.md)],
                    spacing: VennSpacing.md
                ) {
                    ForEach(Array(vibes.enumerated()), id: \.element.id) { index, vibe in
                        VibeCard(
                            vibe: vibe,
                            isSelected: viewModel.perfectNight == vibe,
                            delay: Double(index) * 0.08
                        ) {
                            withAnimation(VennAnimation.bouncy) {
                                viewModel.perfectNight = vibe
                            }
                            Task { @MainActor in HapticManager.shared.impact(.medium) }
                        }
                        .opacity(cardsAppeared ? 1 : 0)
                        .offset(y: cardsAppeared ? 0 : 30)
                        .animation(VennAnimation.standard.delay(Double(index) * 0.08 + 0.2), value: cardsAppeared)
                    }
                }
                .padding(.horizontal, VennSpacing.xxl)
            }
            .padding(.bottom, VennSpacing.xxxl)
        }
        .onAppear {
            cardsAppeared = true
        }
    }
}

private struct VibeCard: View {
    let vibe: NightVibe
    let isSelected: Bool
    let delay: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Rich gradient background
                RoundedRectangle(cornerRadius: VennRadius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [vibe.primaryColor.opacity(0.22), vibe.secondaryColor.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Subtle animated pattern overlay
                RoundedRectangle(cornerRadius: VennRadius.xl, style: .continuous)
                    .fill(VennColors.glassLight)

                // Selection glow border
                RoundedRectangle(cornerRadius: VennRadius.xl, style: .continuous)
                    .stroke(
                        isSelected
                        ? LinearGradient(colors: [vibe.primaryColor, vibe.secondaryColor],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [VennColors.borderSubtle, VennColors.borderSubtle],
                                         startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isSelected ? 1.5 : 1
                    )

                VStack(spacing: VennSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(vibe.primaryColor.opacity(0.18))
                            .frame(width: 60, height: 60)

                        Image(systemName: vibe.icon)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [vibe.primaryColor, vibe.secondaryColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(color: isSelected ? vibe.primaryColor.opacity(0.5) : .clear, radius: 12)

                    VStack(spacing: 4) {
                        Text(vibe.rawValue)
                            .font(VennTypography.bodyMedium)
                            .foregroundColor(VennColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Text(vibe.tagline)
                            .font(VennTypography.caption)
                            .foregroundColor(VennColors.textTertiary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                .padding(VennSpacing.lg)

                // Checkmark overlay
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(vibe.primaryColor)
                                    .frame(width: 22, height: 22)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                    .padding(VennSpacing.md)
                }
            }
            .frame(height: 160)
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .shadow(
                color: isSelected ? vibe.primaryColor.opacity(0.25) : .black.opacity(0.25),
                radius: isSelected ? 20 : 8,
                y: 4
            )
        }
        .buttonStyle(.plain)
        .animation(VennAnimation.snappy, value: isSelected)
    }
}

// MARK: - Step 3: Interests

private struct Step3InterestsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var tagsAppeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: VennSpacing.xxl) {
                StepHeader(
                    title: "What Excites You",
                    subtitle: "Pick at least 3 things that light you up."
                )
                .padding(.top, VennSpacing.xl)

                // Count indicator
                HStack {
                    Spacer()
                    Text("\(viewModel.selectedInterests.count)/\(OnboardingViewModel.allInterests.count) selected")
                        .font(VennTypography.captionBold)
                        .foregroundColor(viewModel.selectedInterests.count >= 3
                                         ? VennColors.coral : VennColors.textTertiary)
                        .animation(VennAnimation.micro, value: viewModel.selectedInterests.count)
                }
                .padding(.horizontal, VennSpacing.xxl)

                // Wrap layout via flow
                InterestTagCloud(
                    tags: OnboardingViewModel.allInterests,
                    selectedTags: $viewModel.selectedInterests,
                    appeared: tagsAppeared
                )
                .padding(.horizontal, VennSpacing.xxl)

                Spacer(minLength: VennSpacing.xxxl)
            }
            .padding(.bottom, VennSpacing.xxxl)
        }
        .onAppear {
            withAnimation(VennAnimation.standard.delay(0.3)) { tagsAppeared = true }
        }
    }
}

private struct InterestTagCloud: View {
    let tags: [String]
    @Binding var selectedTags: Set<String>
    let appeared: Bool

    var body: some View {
        // Manual flow layout using wrapped rows
        let rows = buildRows(tags: tags, containerWidth: UIScreen.main.bounds.width - 48)

        VStack(alignment: .leading, spacing: VennSpacing.sm) {
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: VennSpacing.sm) {
                    ForEach(Array(row.enumerated()), id: \.element) { colIndex, tag in
                        InterestTag(
                            label: tag,
                            isSelected: selectedTags.contains(tag)
                        ) {
                            withAnimation(VennAnimation.snappy) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                            Task { @MainActor in HapticManager.shared.impact(.light) }
                        }
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.85)
                        .animation(
                            VennAnimation.bouncy.delay(Double(rowIndex * 3 + colIndex) * 0.03 + 0.1),
                            value: appeared
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func buildRows(tags: [String], containerWidth: CGFloat) -> [[String]] {
        var rows: [[String]] = [[]]
        var currentWidth: CGFloat = 0
        let spacing: CGFloat = VennSpacing.sm
        let padding: CGFloat = VennSpacing.xl * 2 + VennSpacing.md * 2  // inner + text

        for tag in tags {
            let tagWidth = CGFloat(tag.count) * 8.5 + padding
            if currentWidth + tagWidth + spacing > containerWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentWidth = 0
            }
            rows[rows.count - 1].append(tag)
            currentWidth += tagWidth + spacing
        }
        return rows
    }
}

private struct InterestTag: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(VennTypography.captionBold)
                .foregroundColor(isSelected ? .white : VennColors.textSecondary)
                .padding(.horizontal, VennSpacing.md)
                .padding(.vertical, VennSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected
                              ? AnyShapeStyle(LinearGradient(colors: [VennColors.coral, VennColors.gold],
                                                             startPoint: .leading, endPoint: .trailing))
                              : AnyShapeStyle(VennColors.glassLight))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? VennColors.coral.opacity(0.0) : VennColors.borderMedium, lineWidth: 1)
                        )
                        .shadow(color: isSelected ? VennColors.coral.opacity(0.3) : .clear, radius: 6)
                )
                .scaleEffect(isSelected ? 1.04 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(VennAnimation.snappy, value: isSelected)
    }
}

// MARK: - Step 4: Social Style

private struct Step4SocialStyleView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var goalsAppeared = false
    @State private var rolesAppeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: VennSpacing.xxxl) {
                StepHeader(
                    title: "Your Social Style",
                    subtitle: "Help us understand what you're looking for and who you are in the group."
                )
                .padding(.top, VennSpacing.xl)

                // Goals section
                VStack(alignment: .leading, spacing: VennSpacing.lg) {
                    Text("What are you looking for?")
                        .font(VennTypography.bodyMedium)
                        .foregroundColor(VennColors.textSecondary)
                        .padding(.horizontal, VennSpacing.xxl)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: VennSpacing.md) {
                            ForEach(Array(ConnectionGoal.allCases.enumerated()),
                                    id: \.element.id) { index, goal in
                                GoalCard(
                                    goal: goal,
                                    isSelected: viewModel.selectedConnectionGoals.contains(goal)
                                ) {
                                    withAnimation(VennAnimation.snappy) {
                                        if viewModel.selectedConnectionGoals.contains(goal) {
                                            viewModel.selectedConnectionGoals.remove(goal)
                                        } else {
                                            viewModel.selectedConnectionGoals.insert(goal)
                                        }
                                    }
                                    Task { @MainActor in HapticManager.shared.impact(.light) }
                                }
                                .opacity(goalsAppeared ? 1 : 0)
                                .offset(x: goalsAppeared ? 0 : 20)
                                .animation(VennAnimation.standard.delay(Double(index) * 0.07 + 0.2),
                                           value: goalsAppeared)
                            }
                        }
                        .padding(.horizontal, VennSpacing.xxl)
                    }
                }

                // Role section
                VStack(alignment: .leading, spacing: VennSpacing.lg) {
                    Text("In a group, you're...")
                        .font(VennTypography.bodyMedium)
                        .foregroundColor(VennColors.textSecondary)
                        .padding(.horizontal, VennSpacing.xxl)

                    VStack(spacing: VennSpacing.sm) {
                        ForEach(Array(SocialRole.allCases.enumerated()),
                                id: \.element.id) { index, role in
                            RoleCard(
                                role: role,
                                isSelected: viewModel.groupRole == role
                            ) {
                                withAnimation(VennAnimation.snappy) {
                                    viewModel.groupRole = role
                                }
                                Task { @MainActor in HapticManager.shared.selectionFeedback() }
                            }
                            .opacity(rolesAppeared ? 1 : 0)
                            .offset(y: rolesAppeared ? 0 : 16)
                            .animation(VennAnimation.standard.delay(Double(index) * 0.07 + 0.3),
                                       value: rolesAppeared)
                        }
                    }
                    .padding(.horizontal, VennSpacing.xxl)
                }

                Spacer(minLength: VennSpacing.xxxl)
            }
            .padding(.bottom, VennSpacing.xxxl)
        }
        .onAppear {
            withAnimation(VennAnimation.standard.delay(0.2)) { goalsAppeared = true }
            withAnimation(VennAnimation.standard.delay(0.4)) { rolesAppeared = true }
        }
    }
}

private struct GoalCard: View {
    let goal: ConnectionGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: VennSpacing.sm) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(VennColors.coral)
                        .transition(.scale.combined(with: .opacity))
                }
                Text(goal.rawValue)
                    .font(VennTypography.captionBold)
                    .foregroundColor(isSelected ? VennColors.textPrimary : VennColors.textSecondary)
            }
            .padding(.horizontal, VennSpacing.lg)
            .padding(.vertical, VennSpacing.md)
            .background(
                Capsule()
                    .fill(isSelected ? VennColors.coralSubtle : VennColors.surfacePrimary)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? VennColors.coral.opacity(0.5) : VennColors.borderMedium, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(VennAnimation.snappy, value: isSelected)
    }
}

private struct RoleCard: View {
    let role: SocialRole
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: VennSpacing.md) {
                // Left accent bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [VennColors.coral, VennColors.gold],
                                         startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [VennColors.borderSubtle, VennColors.borderSubtle],
                                         startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 3, height: 50)
                    .animation(VennAnimation.snappy, value: isSelected)

                Text(role.emoji)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 3) {
                    Text(role.rawValue)
                        .font(VennTypography.bodyMedium)
                        .foregroundColor(isSelected ? VennColors.textPrimary : VennColors.textSecondary)

                    Text(role.description)
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textTertiary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(colors: [VennColors.coral, VennColors.gold],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(VennSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                    .fill(isSelected ? VennColors.coralSubtle : VennColors.surfacePrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                            .stroke(isSelected ? VennColors.coral.opacity(0.3) : VennColors.borderSubtle,
                                    lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(VennAnimation.snappy, value: isSelected)
    }
}

// MARK: - Step 5: Complete

private struct Step5CompleteView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let authManager: AuthenticationManager

    @State private var heroAppeared = false
    @State private var cardAppeared = false
    @State private var ctaAppeared = false
    @State private var ctaPressed = false
    @State private var orbitAngle: Double = 0
    @State private var glowPulse = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: VennSpacing.xxxl) {
                Spacer(minLength: VennSpacing.xl)

                // Hero orbit animation
                ZStack {
                    Circle()
                        .stroke(VennColors.coral.opacity(0.08), lineWidth: 1)
                        .frame(width: 180, height: 180)

                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(
                                LinearGradient(colors: [VennColors.coral, VennColors.gold],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 8, height: 8)
                            .offset(y: -90)
                            .rotationEffect(.degrees(orbitAngle + Double(i) * 120))
                    }

                    Circle()
                        .stroke(VennColors.gold.opacity(0.12), lineWidth: 1)
                        .frame(width: 130, height: 130)

                    Circle()
                        .fill(VennColors.coral.opacity(glowPulse ? 0.15 : 0.06))
                        .frame(width: 100, height: 100)
                        .blur(radius: 15)

                    Circle()
                        .fill(VennColors.surfacePrimary)
                        .frame(width: 90, height: 90)

                    Image(systemName: "sparkles")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(VennGradients.primary)
                }
                .scaleEffect(heroAppeared ? 1 : 0.5)
                .opacity(heroAppeared ? 1 : 0)

                // Headline
                VStack(spacing: VennSpacing.sm) {
                    Text("You're All Set")
                        .font(VennTypography.displayMedium)
                        .foregroundColor(VennColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(heroAppeared ? 1 : 0)
                        .offset(y: heroAppeared ? 0 : 16)

                    Text("Venn now knows your vibe.")
                        .font(VennTypography.bodyLarge)
                        .foregroundColor(VennColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(heroAppeared ? 1 : 0)
                        .offset(y: heroAppeared ? 0 : 10)
                }

                // Profile summary card
                profileSummaryCard
                    .opacity(cardAppeared ? 1 : 0)
                    .offset(y: cardAppeared ? 0 : 20)

                // CTA button
                Button {
                    Task { @MainActor in HapticManager.shared.success() }
                    viewModel.completeOnboarding()
                    authManager.completeOnboarding()
                } label: {
                    HStack(spacing: VennSpacing.sm) {
                        Text("Let's Go")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(colors: [VennColors.coral, VennColors.gold],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .shadow(color: VennColors.coral.opacity(0.45), radius: 20, y: 8)
                    )
                }
                .buttonStyle(.plain)
                .scaleEffect(ctaPressed ? 0.96 : 1.0)
                .animation(VennAnimation.micro, value: ctaPressed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in ctaPressed = true }
                        .onEnded { _ in ctaPressed = false }
                )
                .opacity(ctaAppeared ? 1 : 0)
                .offset(y: ctaAppeared ? 0 : 16)
                .padding(.horizontal, VennSpacing.xxl)

                Spacer(minLength: VennSpacing.xxxl)
            }
            .padding(.horizontal, VennSpacing.xxl)
        }
        .onAppear {
            withAnimation(VennAnimation.bouncy.delay(0.1)) { heroAppeared = true }
            withAnimation(VennAnimation.standard.delay(0.5)) { cardAppeared = true }
            withAnimation(VennAnimation.standard.delay(0.8)) { ctaAppeared = true }
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) { orbitAngle = 360 }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { glowPulse = true }
        }
    }

    private var profileSummaryCard: some View {
        VStack(spacing: VennSpacing.lg) {
            HStack {
                Text("Your Profile")
                    .font(VennTypography.bodyMedium)
                    .foregroundColor(VennColors.textSecondary)
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .foregroundStyle(VennGradients.primary)
                    .font(.system(size: 18))
            }

            Divider()
                .background(VennColors.borderSubtle)

            VStack(spacing: VennSpacing.md) {
                SummaryRow(
                    icon: "slider.horizontal.3",
                    label: "Energy",
                    value: energyLabel
                )
                SummaryRow(
                    icon: "battery.100",
                    label: "Battery",
                    value: viewModel.socialBattery.rawValue
                )
                if let vibe = viewModel.perfectNight {
                    SummaryRow(
                        icon: vibe.icon,
                        label: "Night",
                        value: vibe.rawValue
                    )
                }
                SummaryRow(
                    icon: "tag.fill",
                    label: "Interests",
                    value: "\(viewModel.selectedInterests.count) picked"
                )
                if let role = viewModel.groupRole {
                    SummaryRow(
                        icon: "person.fill",
                        label: "You're",
                        value: role.rawValue
                    )
                }
            }
        }
        .padding(VennSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: VennRadius.xl, style: .continuous)
                .fill(VennColors.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: VennRadius.xl, style: .continuous)
                        .stroke(VennColors.borderSubtle, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
        )
    }

    private var energyLabel: String {
        switch viewModel.introExtrovert {
        case 0..<0.33: return "Introverted"
        case 0.33..<0.66: return "Ambivert"
        default: return "Extroverted"
        }
    }
}

private struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(VennColors.coral)
                .frame(width: 20)

            Text(label)
                .font(VennTypography.caption)
                .foregroundColor(VennColors.textTertiary)

            Spacer()

            Text(value)
                .font(VennTypography.captionBold)
                .foregroundColor(VennColors.textPrimary)
        }
    }
}

// MARK: - Confetti Burst View

private struct OnboardingConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var exploded = false
    @State private var faded = false

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.35)
            ForEach(particles) { p in
                RoundedRectangle(cornerRadius: 2)
                    .fill(p.color)
                    .frame(width: p.width, height: p.height)
                    .rotationEffect(.degrees(exploded ? p.rotation : 0))
                    .position(
                        x: center.x + (exploded ? CGFloat(cos(p.angle)) * p.distance : 0),
                        y: center.y + (exploded ? CGFloat(sin(p.angle)) * p.distance : 0)
                    )
                    .opacity(faded ? 0 : 1)
                    .animation(
                        .spring(response: 0.7, dampingFraction: 0.5).delay(p.delay),
                        value: exploded
                    )
                    .animation(.easeOut(duration: 0.8).delay(1.2), value: faded)
            }
        }
        .onAppear {
            generateParticles()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { exploded = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { faded = true }
        }
    }

    private func generateParticles() {
        let colors: [Color] = [VennColors.coral, VennColors.gold, VennColors.indigo, VennColors.success, .white]
        particles = (0..<55).map { i in
            ConfettiParticle(
                id: i,
                color: colors[i % colors.count],
                width: CGFloat.random(in: 4...9),
                height: CGFloat.random(in: 6...16),
                angle: Double.random(in: 0...(2 * .pi)),
                distance: CGFloat.random(in: 80...270),
                rotation: Double.random(in: -360...360),
                delay: Double.random(in: 0...0.25)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingFlowView()
        .environmentObject(AuthenticationManager.shared)
}
