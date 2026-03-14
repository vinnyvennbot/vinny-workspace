import Foundation
import SwiftUI

// MARK: - Onboarding Step

/// Each case maps to one full-screen preference-collection screen.
enum OnboardingStep: Int, CaseIterable {
    case personality    = 0  // Intro/extrovert slider + social battery
    case perfectNight   = 1  // Single-select card grid
    case interests      = 2  // Multi-select chip grid (minimum 2 required)
    case connectionGoals = 3 // Multi-select list
    case socialStyle    = 4  // Group role + social styles

    var title: String {
        switch self {
        case .personality:     return "What's your social style?"
        case .perfectNight:    return "Your perfect night looks like…"
        case .interests:       return "What are you into?"
        case .connectionGoals: return "What are you looking for?"
        case .socialStyle:     return "How do you show up?"
        }
    }

    var subtitle: String {
        switch self {
        case .personality:
            return "This helps Vivi match you with the right people and experiences."
        case .perfectNight:
            return "Pick the vibe that resonates most."
        case .interests:
            return "Select at least 2 — the more you pick, the better your matches."
        case .connectionGoals:
            return "Choose everything that applies."
        case .socialStyle:
            return "Pick your role and how you prefer to socialise."
        }
    }

    var analyticsName: String {
        switch self {
        case .personality:     return "personality"
        case .perfectNight:    return "perfect_night"
        case .interests:       return "interests"
        case .connectionGoals: return "connection_goals"
        case .socialStyle:     return "social_style"
        }
    }
}

// MARK: - Onboarding Enums
//
// Rich UI types used by both OnboardingViewModel and the view layer.
// Defined at module scope (not nested) so views can reference them directly.

enum SocialBattery: String, CaseIterable, Identifiable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"

    var id: String { rawValue }

    /// Backend serialisation value sent in the profile payload.
    var apiValue: String {
        switch self {
        case .low:    return "low"
        case .medium: return "medium"
        case .high:   return "high"
        }
    }
}

enum NightVibe: String, CaseIterable, Identifiable {
    case intimateDinner  = "Intimate Dinner"
    case danceFloor      = "Dance Floor"
    case adventure       = "Adventure"
    case networking      = "Networking"

    var id: String { rawValue }

    /// Backend serialisation value sent as `onboarding_intent`.
    var apiValue: String {
        switch self {
        case .intimateDinner: return "intimate"
        case .danceFloor:     return "dancing"
        case .adventure:      return "adventure"
        case .networking:     return "networking"
        }
    }

    var icon: String {
        switch self {
        case .intimateDinner: return "wineglass.fill"
        case .danceFloor:     return "music.note"
        case .adventure:      return "location.north.fill"
        case .networking:     return "person.2.fill"
        }
    }

    var tagline: String {
        switch self {
        case .intimateDinner: return "Good food, great company"
        case .danceFloor:     return "Move until midnight"
        case .adventure:      return "No plan, just vibes"
        case .networking:     return "Build your world"
        }
    }

    var primaryColor: Color {
        switch self {
        case .intimateDinner: return VennColors.gold
        case .danceFloor:     return VennColors.coral
        case .adventure:      return Color(hex: "#4ADE80")
        case .networking:     return VennColors.indigo
        }
    }

    var secondaryColor: Color {
        switch self {
        case .intimateDinner: return VennColors.coral
        case .danceFloor:     return VennColors.indigo
        case .adventure:      return VennColors.gold
        case .networking:     return Color(hex: "#CBD5E1")
        }
    }
}

enum ConnectionGoal: String, CaseIterable, Identifiable {
    case meetNewPeople       = "Meet New People"
    case activityPartners    = "Find Activity Partners"
    case expandCircle        = "Expand My Circle"
    case dateNights          = "Date Nights"
    case professionalNetwork = "Professional Network"
    case adventureBuddies    = "Adventure Buddies"

    var id: String { rawValue }
}

enum SocialRole: String, CaseIterable, Identifiable {
    case planner     = "The Planner"
    case connector   = "The Connector"
    case lifeOfParty = "The Life of the Party"
    case explorer    = "The Explorer"
    case chillOne    = "The Chill One"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .planner:     return "📋"
        case .connector:   return "🔗"
        case .lifeOfParty: return "✨"
        case .explorer:    return "🧭"
        case .chillOne:    return "✌️"
        }
    }

    var description: String {
        switch self {
        case .planner:     return "You've got the reservation, the Uber, and a backup plan."
        case .connector:   return "You already know someone who knows someone."
        case .lifeOfParty: return "Energy personified. The room shifts when you walk in."
        case .explorer:    return "First to suggest the weird new spot. Always right about it."
        case .chillOne:    return "Vibes over schedules. You're the calm in the chaos."
        }
    }
}

// MARK: - Onboarding Profile Payload
//
// Dedicated Encodable + Decodable struct that maps every preference field to
// the snake_case keys expected by PUT /user/profile on the backend.
// Decodable conformance enables local persistence and offline retry.

struct OnboardingProfilePayload: Codable {
    /// Backend stores intro/extrovert as a String representation of a 0.0–1.0 Double.
    let intro_extrovert: String
    /// "low" | "medium" | "high"
    let social_battery: String
    /// Backend field: "onboarding_intent". Values: "intimate" | "dancing" | "adventure" | "networking"
    let onboarding_intent: String
    let interests: [String]
    let connection_goals: [String]
    let group_role: String
    let social_styles: [String]
    /// Signals to the backend that onboarding is complete — flips is_onboarded.
    let is_onboarded: Bool
}

// MARK: - OnboardingViewModel
//
// Authoritative ObservableObject for the real preference-collection flow.
// This file is the single definition of OnboardingViewModel in the module —
// the lightweight stub inside EnhancedOnboardingFlow.swift must be removed
// once this file is added to the Xcode project.

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: Step Navigation

    @Published private(set) var currentStep: OnboardingStep = .personality

    let totalSteps: Int = OnboardingStep.allCases.count

    /// 0.0 – 1.0 progress fraction suitable for a SwiftUI ProgressView.
    var progressFraction: Double {
        Double(currentStep.rawValue + 1) / Double(totalSteps)
    }

    var isFirstStep: Bool { currentStep == .personality }
    var isLastStep:  Bool { currentStep == .socialStyle }

    // MARK: Step 1 — Personality

    /// 0.0 = full introvert, 1.0 = full extrovert.
    /// Stored as Double for smooth slider UX; serialised to String for the backend.
    @Published var introExtrovert: Double = 0.5

    /// Social battery level selection.
    @Published var socialBattery: SocialBattery = .medium

    // MARK: Step 2 — Perfect Night

    /// Selected night vibe — nil until the user makes a choice.
    @Published var perfectNight: NightVibe? = nil

    // MARK: Step 3 — Interests

    @Published var selectedInterests: Set<String> = []

    // MARK: Step 4 — Connection Goals

    @Published var selectedConnectionGoals: Set<ConnectionGoal> = []

    // MARK: Step 5 — Social Style

    /// Single-select group role
    @Published var groupRole: SocialRole? = nil

    /// Multi-select social styles
    @Published var selectedSocialStyles: Set<String> = []

    // MARK: UI State

    @Published private(set) var isSaving: Bool = false

    /// Non-nil when a save attempt produced a user-visible error.
    /// Network fallbacks are handled silently; this surfaces only unexpected errors.
    @Published private(set) var saveError: String? = nil

    // MARK: Page Data
    //
    // Retained for compatibility with EnhancedOnboardingFlow's TabView scaffold
    // until the full preference-collection UI is wired up.

    @Published var pages: [OnboardingPageData] = []

    // MARK: Dependencies

    private let authManager: AuthenticationManager
    private let analytics: AnalyticsService
    private let defaults: UserDefaults

    // MARK: Persistence Key

    private enum PersistenceKey {
        static let pendingProfile = "venn_pending_onboarding_profile"
    }

    // MARK: Init

    init(
        authManager: AuthenticationManager = .shared,
        analytics: AnalyticsService = .shared,
        defaults: UserDefaults = .standard
    ) {
        self.authManager = authManager
        self.analytics = analytics
        self.defaults = defaults
        setupPages()
        Task { await analytics.track(event: .onboardingStarted) }
    }

    // MARK: - Step Navigation

    func advance() {
        guard canAdvance else { return }
        Task { await trackStepComplete() }
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            currentStep = next
        }
    }

    func goBack() {
        guard !isFirstStep,
              let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            currentStep = prev
        }
    }

    // MARK: - Per-Step Validation

    /// True when the current step (driven by the ViewModel's own currentStep) contains
    /// enough data to proceed.
    var canAdvance: Bool {
        isStepValid(currentStep.rawValue)
    }

    /// Validates a step by its integer index. Used by OnboardingFlowView which
    /// manages its own local Int step counter for the swipeable content.
    func isStepValid(_ step: Int) -> Bool {
        switch step {
        case 0: return true                                       // slider always has a value; battery defaults to .medium
        case 1: return perfectNight != nil
        case 2: return selectedInterests.count >= 3
        case 3: return !selectedConnectionGoals.isEmpty && groupRole != nil
        case 4: return true                                       // completion screen
        default: return true
        }
    }

    /// Human-readable hint shown below the primary CTA when the step is incomplete.
    var validationHint: String? {
        switch currentStep {
        case .personality:
            return nil  // battery defaults to .medium so always valid
        case .perfectNight:
            return perfectNight == nil ? "Pick a vibe to continue." : nil
        case .interests:
            let remaining = max(0, 3 - selectedInterests.count)
            return remaining > 0
                ? "Select \(remaining) more interest\(remaining == 1 ? "" : "s")."
                : nil
        case .connectionGoals:
            if selectedConnectionGoals.isEmpty { return "Choose at least one goal." }
            if groupRole == nil { return "Choose your group role." }
            return nil
        case .socialStyle:
            if selectedSocialStyles.isEmpty { return "Select at least one social style." }
            return nil
        }
    }

    // MARK: - Selection Toggles

    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    func toggleConnectionGoal(_ goal: ConnectionGoal) {
        if selectedConnectionGoals.contains(goal) {
            selectedConnectionGoals.remove(goal)
        } else {
            selectedConnectionGoals.insert(goal)
        }
    }

    func toggleSocialStyle(_ style: String) {
        if selectedSocialStyles.contains(style) {
            selectedSocialStyles.remove(style)
        } else {
            selectedSocialStyles.insert(style)
        }
    }

    // MARK: - Save Profile

    /// Constructs the profile payload, calls PUT /user/profile via a direct
    /// URLRequest (bridging the existing NetworkClient actor pattern), and
    /// falls back gracefully to local UserDefaults persistence if the network
    /// is unavailable so onboarding is never blocked.
    func saveProfile() async {
        isSaving = true
        saveError = nil

        let payload = buildPayload()

        do {
            try await performNetworkSave(payload)
            clearPendingProfile()
            #if DEBUG
            print("[OnboardingViewModel] Profile saved to backend successfully.")
            #endif
        } catch {
            #if DEBUG
            print("[OnboardingViewModel] Network save failed (\(error.localizedDescription)). Persisting locally for retry.")
            #endif
            persistProfileLocally(payload)
            // Intentionally not setting saveError — the user flow continues.
        }

        isSaving = false
    }

    // MARK: - Complete Onboarding

    /// Primary completion entry point.
    /// Saves the profile (with silent offline fallback), fires the analytics
    /// event, then tells AuthenticationManager to clear the needsOnboarding
    /// flag so RootView navigates to the main tab bar.
    func completeOnboarding() {
        Task {
            await saveProfile()
            await analytics.track(event: .onboardingCompleted)
            authManager.completeOnboarding()
            defaults.set(true, forKey: "hasCompletedOnboarding")
        }
    }

    // MARK: - Offline Retry

    /// Retry a profile save that failed during onboarding.
    /// Call this from AppState or AuthenticationManager after a successful
    /// token refresh or when connectivity is restored.
    func retryPendingProfileSaveIfNeeded() async {
        guard
            let data = defaults.data(forKey: PersistenceKey.pendingProfile),
            let payload = try? JSONDecoder().decode(OnboardingProfilePayload.self, from: data)
        else { return }

        #if DEBUG
        print("[OnboardingViewModel] Retrying pending onboarding profile save…")
        #endif

        do {
            try await performNetworkSave(payload)
            clearPendingProfile()
            #if DEBUG
            print("[OnboardingViewModel] Pending profile retry succeeded.")
            #endif
        } catch {
            #if DEBUG
            print("[OnboardingViewModel] Pending profile retry failed: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Private: Payload Construction

    private func buildPayload() -> OnboardingProfilePayload {
        OnboardingProfilePayload(
            intro_extrovert: String(format: "%.2f", introExtrovert),
            social_battery: socialBattery.apiValue,
            onboarding_intent: perfectNight?.apiValue ?? "",
            interests: Array(selectedInterests).sorted(),
            connection_goals: Array(selectedConnectionGoals).map(\.rawValue).sorted(),
            group_role: groupRole?.rawValue ?? "",
            social_styles: Array(selectedSocialStyles).sorted(),
            is_onboarded: true
        )
    }

    // MARK: - Private: Network

    /// Sends the payload to PUT /user/profile with a Bearer token sourced
    /// from the Keychain — mirroring exactly how NetworkClient builds requests.
    ///
    /// Design note: this method intentionally avoids adding a new case to the
    /// APIEndpoint enum (which would require changes to NetworkClient.swift) so
    /// this ViewModel ships as a standalone file. Consolidate into APIEndpoint
    /// during the next networking layer refactor.
    private func performNetworkSave(_ payload: OnboardingProfilePayload) async throws {
        let url = URL(string: "https://api.vennsocial.co/api/staging/user/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let tokens = await KeychainService.shared.getTokens()
        if let token = tokens.access {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(payload)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.clientError(http.statusCode)
        case 500...599:
            throw NetworkError.serverError(http.statusCode)
        default:
            throw NetworkError.unknown
        }
    }

    // MARK: - Private: Local Persistence

    private func persistProfileLocally(_ payload: OnboardingProfilePayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        defaults.set(data, forKey: PersistenceKey.pendingProfile)
    }

    private func clearPendingProfile() {
        defaults.removeObject(forKey: PersistenceKey.pendingProfile)
    }

    // MARK: - Private: Analytics

    private func trackStepComplete() async {
        await analytics.track(
            event: .onboardingStepCompleted,
            properties: [
                "step_index": currentStep.rawValue,
                "step_name": currentStep.analyticsName
            ]
        )
    }

    // MARK: - Private: Page Data (EnhancedOnboardingFlow compat)

    private func setupPages() {
        pages = [
            OnboardingPageData(
                icon: "sparkles",
                title: "Discover Amazing Events",
                description: "Find curated experiences that match your vibe.",
                color: VennColors.coral
            ),
            OnboardingPageData(
                icon: "person.2.fill",
                title: "Meet Like-Minded People",
                description: "Connect with your people at events designed for genuine connection.",
                color: VennColors.gold
            ),
            OnboardingPageData(
                icon: "wand.and.stars",
                title: "Vivi, Your AI Concierge",
                description: "Personalised recommendations so you never miss the perfect event.",
                color: .purple
            ),
            OnboardingPageData(
                icon: "heart.fill",
                title: "Create Unforgettable Memories",
                description: "Every event is a story waiting to happen. Let's make yours incredible.",
                color: Color(red: 255 / 255, green: 100 / 255, blue: 150 / 255)
            )
        ]
    }
}

// MARK: - Static Catalogue Data

extension OnboardingViewModel {

    static let allInterests: [String] = [
        "Live Music", "Wine & Dine", "Art & Culture", "Fitness", "Dancing",
        "Rooftop Bars", "Comedy Shows", "Outdoor Adventures", "Brunch", "Cocktails",
        "Gaming", "Karaoke", "Jazz", "Food Festivals", "Yoga",
        "Nightlife", "Gallery Openings", "Sports", "Theater", "Beach Days"
    ]

    static let allConnectionGoals: [String] = [
        "Meet New People", "Find Activity Partners", "Expand My Circle",
        "Date Nights", "Professional Network", "Adventure Buddies"
    ]

    static let allGroupRoles: [String] = [
        "The Planner", "The Connector", "The Life of the Party",
        "The Explorer", "The Chill One"
    ]

    static let allSocialStyles: [String] = [
        "Small Groups", "Big Events", "One-on-One",
        "Spontaneous Plans", "Planned Ahead"
    ]

    /// Each tuple: (backend id, display label, SF Symbol name)
    static let allPerfectNights: [(id: String, label: String, icon: String)] = [
        ("intimate",   "Intimate Dinner",   "fork.knife"),
        ("dancing",    "Dancing All Night", "music.note"),
        ("adventure",  "Wild Adventure",    "mountain.2.fill"),
        ("networking", "Networking Event",  "person.3.fill")
    ]

    /// Each tuple: (backend id, display label, SF Symbol name)
    static let allSocialBatteries: [(id: String, label: String, icon: String)] = [
        ("low",    "Rechargeable — I need downtime", "battery.25"),
        ("medium", "Balanced — I pace myself",       "battery.50"),
        ("high",   "Always on — I thrive in crowds", "battery.100")
    ]
}
