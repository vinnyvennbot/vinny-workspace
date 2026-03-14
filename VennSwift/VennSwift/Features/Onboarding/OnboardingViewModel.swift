import SwiftUI
import CoreLocation

// MARK: - API Response Models

struct OnboardingStartResponse: Decodable {
    let conversationId: String
    let message: String
    let insightsCount: Int

    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case message
        case insightsCount = "insights_count"
    }
}

struct OnboardingMessageResponse: Decodable {
    let message: String
    let isComplete: Bool
    let insightsCount: Int
    let coverage: OnboardingCoverageData?
    let completionReason: String?

    enum CodingKeys: String, CodingKey {
        case message
        case isComplete = "is_complete"
        case insightsCount = "insights_count"
        case coverage
        case completionReason = "completion_reason"
    }
}

struct OnboardingCoverageData: Decodable {
    let messageCount: Int
    let observationCount: Int
    let readyToComplete: Bool
    let goodCoverage: Bool

    enum CodingKeys: String, CodingKey {
        case messageCount = "message_count"
        case observationCount = "observation_count"
        case readyToComplete = "ready_to_complete"
        case goodCoverage = "good_coverage"
    }
}

struct OnboardingSkipResponse: Decodable {
    let success: Bool
    let message: String
    let insightsCount: Int

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case insightsCount = "insights_count"
    }
}

// MARK: - LocationManager

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var hasReceivedLocation = false

    @Published var coordinate: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var cityName: String = ""
    @Published var locationFailed: Bool = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startLocating() {
        guard !hasReceivedLocation else { return }
        // Use continuous updates — more reliable on simulator than requestLocation()
        manager.startUpdatingLocation()

        // Timeout fallback: if no location after 5s, mark as failed so UI can offer manual skip
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self, !self.hasReceivedLocation else { return }
            self.locationFailed = true
        }
    }

    // MARK: CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = manager.authorizationStatus
        }
        // Auto-start if already authorized
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            startLocating()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        hasReceivedLocation = true
        manager.stopUpdatingLocation()
        DispatchQueue.main.async { [weak self] in
            self?.coordinate = location.coordinate
            self?.locationFailed = false
        }
        reverseGeocodeLocation(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
        print("LocationManager failed: \(error)")
        #endif
        // CLError.locationUnknown is transient — don't fail on it
        if let clError = error as? CLError, clError.code != .locationUnknown {
            DispatchQueue.main.async { [weak self] in
                self?.locationFailed = true
            }
        }
    }

    // MARK: Reverse Geocoding

    private func reverseGeocodeLocation(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.cityName = city
                }
            }
        }
    }
}

// MARK: - OnboardingViewModel

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: Types

    enum Phase: Equatable {
        case hook
        case location
        case conversation
        case reveal
    }

    struct ChatMessage: Identifiable, Equatable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp = Date()
        static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool { lhs.id == rhs.id }
    }

    struct InsightCard: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let subtitle: String
        let accent: Color
    }

    struct PersonalityResult {
        let type: String
        let icon: String      // SF Symbol name
        let summary: String
    }

    struct WaitlistHotspot: Identifiable {
        let id = UUID()
        let city: String
        let coordinate: CLLocationCoordinate2D
        let count: Int
        /// Normalized 0–1 intensity for glow sizing
        var intensity: Double { min(1.0, Double(count) / 600.0) }
    }

    // MARK: Service Area

    static let serviceAreaCenter = CLLocationCoordinate2D(latitude: 37.55, longitude: -122.1)
    static let serviceAreaRadiusKm: Double = 65.0

    static let serviceAreaPolygon: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 38.02, longitude: -122.95),  // NW - Point Reyes
        CLLocationCoordinate2D(latitude: 38.08, longitude: -122.15),  // N - Vallejo
        CLLocationCoordinate2D(latitude: 37.95, longitude: -121.70),  // NE - Antioch
        CLLocationCoordinate2D(latitude: 37.35, longitude: -121.65),  // E - San Jose east
        CLLocationCoordinate2D(latitude: 37.15, longitude: -121.85),  // SE - Morgan Hill
        CLLocationCoordinate2D(latitude: 37.10, longitude: -122.10),  // S - Santa Cruz mountains
        CLLocationCoordinate2D(latitude: 37.42, longitude: -122.48),  // SW - Half Moon Bay
        CLLocationCoordinate2D(latitude: 37.70, longitude: -122.52),  // W - Pacifica/Daly City
        CLLocationCoordinate2D(latitude: 37.82, longitude: -122.58),  // Golden Gate
    ]

    // MARK: Published — Phase

    @Published var phase: Phase = .hook

    // MARK: Published — Hook

    @Published var connectionsStat: Int = 0
    @Published var eventsStat: Int = 0
    @Published var matchesStat: Int = 0
    @Published var hookCountersFinished = false

    // MARK: Waitlist Heatmap Data

    static let waitlistHotspots: [WaitlistHotspot] = [
        // Bay Area (already live — shown as "active" dots)
        WaitlistHotspot(city: "San Francisco", coordinate: .init(latitude: 37.7749, longitude: -122.4194), count: 580),
        WaitlistHotspot(city: "Oakland", coordinate: .init(latitude: 37.8044, longitude: -122.2712), count: 320),
        WaitlistHotspot(city: "San Jose", coordinate: .init(latitude: 37.3382, longitude: -121.8863), count: 410),
        WaitlistHotspot(city: "Palo Alto", coordinate: .init(latitude: 37.4419, longitude: -122.1430), count: 290),
        WaitlistHotspot(city: "Berkeley", coordinate: .init(latitude: 37.8716, longitude: -122.2727), count: 260),
        // California waitlist
        WaitlistHotspot(city: "Los Angeles", coordinate: .init(latitude: 34.0522, longitude: -118.2437), count: 520),
        WaitlistHotspot(city: "San Diego", coordinate: .init(latitude: 32.7157, longitude: -117.1611), count: 180),
        WaitlistHotspot(city: "Sacramento", coordinate: .init(latitude: 38.5816, longitude: -121.4944), count: 140),
        // Major US cities
        WaitlistHotspot(city: "New York", coordinate: .init(latitude: 40.7128, longitude: -74.0060), count: 480),
        WaitlistHotspot(city: "Austin", coordinate: .init(latitude: 30.2672, longitude: -97.7431), count: 310),
        WaitlistHotspot(city: "Miami", coordinate: .init(latitude: 25.7617, longitude: -80.1918), count: 270),
        WaitlistHotspot(city: "Chicago", coordinate: .init(latitude: 41.8781, longitude: -87.6298), count: 230),
        WaitlistHotspot(city: "Seattle", coordinate: .init(latitude: 47.6062, longitude: -122.3321), count: 340),
        WaitlistHotspot(city: "Denver", coordinate: .init(latitude: 39.7392, longitude: -104.9903), count: 160),
        WaitlistHotspot(city: "Nashville", coordinate: .init(latitude: 36.1627, longitude: -86.7816), count: 120),
        WaitlistHotspot(city: "Portland", coordinate: .init(latitude: 45.5152, longitude: -122.6784), count: 190),
        WaitlistHotspot(city: "Atlanta", coordinate: .init(latitude: 33.7490, longitude: -84.3880), count: 200),
        WaitlistHotspot(city: "Boston", coordinate: .init(latitude: 42.3601, longitude: -71.0589), count: 170),
    ]

    static var totalWaitlistCount: Int {
        waitlistHotspots.reduce(0) { $0 + $1.count }
    }

    // MARK: Published — Location

    @Published var isInServiceArea: Bool = false
    @Published var locationChecked: Bool = false
    @Published var isCheckingLocation: Bool = false
    @Published var waitlistEmail: String = ""
    @Published var joinedWaitlist: Bool = false
    @Published var waitlistCount: Int = 0
    @Published var detectedCity: String = ""
    @Published var userHotspot: WaitlistHotspot?

    // MARK: Published — Conversation

    @Published var messages: [ChatMessage] = []
    @Published var isViviTyping = false
    @Published var insightCards: [InsightCard] = []
    @Published var understandingProgress: Double = 0
    @Published var quickReplies: [String] = []
    @Published var userInput: String = ""
    @Published var conversationId: String?
    @Published var isConversationComplete = false

    // MARK: Published — Reveal

    @Published var personalityType: String = ""
    @Published var personalityIcon: String = ""
    @Published var personalitySummary: String = ""
    @Published var revealVisible = false
    @Published var recommendedEventsCount: Int = 0
    @Published var similarPeopleCount: Int = 0

    // MARK: Private

    private let networkClient = NetworkClient.shared
    private let authManager: AuthenticationManager
    private var lastInsightCount = 0

    /// Toggle for development — set false when backend is running
    static let useMockAPI = true

    private let insightTemplates: [(icon: String, title: String, subtitle: String)] = [
        ("music.note",      "Music Lover",        "23 live music events this month near you"),
        ("moon.stars",      "Night Owl",           "47 people share your late-night energy"),
        ("fork.knife",      "Foodie",              "15 culinary experiences trending nearby"),
        ("figure.hiking",   "Adventure Seeker",    "8 outdoor experiences this week"),
        ("person.2.fill",   "Social Connector",    "High match potential with 34 people"),
        ("sparkles",        "Creative Soul",       "12 art & culture events curated for you"),
        ("cup.and.saucer.fill", "Cafe Regular",    "9 cozy meetups happening this week"),
        ("bolt.fill",       "Spontaneous Spirit",  "6 last-minute plans people are joining now"),
    ]

    private let insightAccents: [Color] = [
        Color(red: 1.0, green: 0.39, blue: 0.28),
        Color(red: 0.5, green: 0.55, blue: 0.97),
        Color(red: 1.0, green: 0.70, blue: 0.26),
        Color(red: 0.20, green: 0.83, blue: 0.60),
        Color(red: 0.76, green: 0.55, blue: 0.97),
        Color(red: 0.95, green: 0.45, blue: 0.55),
    ]

    init(authManager: AuthenticationManager = .shared) {
        self.authManager = authManager
    }

    // MARK: - Hook Phase

    func animateHookCounters() async {
        let targets = (
            connections: Int.random(in: 180...320),
            events: Int.random(in: 8...24),
            matches: Int.random(in: 5...15)
        )

        let steps = 40
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let eased = 1.0 - pow(1.0 - t, 3)
            connectionsStat = Int(Double(targets.connections) * eased)
            eventsStat = Int(Double(targets.events) * eased)
            matchesStat = Int(Double(targets.matches) * eased)
            try? await Task.sleep(nanoseconds: 30_000_000)
        }
        connectionsStat = targets.connections
        eventsStat = targets.events
        matchesStat = targets.matches
        hookCountersFinished = true
    }

    func advanceToLocation() {
        HapticManager.shared.impact(.medium)
        withAnimation(VennAnimation.gentle) {
            phase = .location
        }
    }

    // MARK: - Location Phase

    func checkLocation(coordinate: CLLocationCoordinate2D) {
        isCheckingLocation = true

        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let center = CLLocation(
            latitude: Self.serviceAreaCenter.latitude,
            longitude: Self.serviceAreaCenter.longitude
        )
        let distanceMeters = userLocation.distance(from: center)
        let distanceKm = distanceMeters / 1000.0

        isInServiceArea = distanceKm <= Self.serviceAreaRadiusKm
        isCheckingLocation = false
        locationChecked = true

        if isInServiceArea {
            waitlistCount = 0
        } else {
            waitlistCount = Int.random(in: 2800...4200)
        }

        HapticManager.shared.impact(isInServiceArea ? .medium : .light)
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            let city = placemarks?.first?.locality ?? ""
            DispatchQueue.main.async {
                self?.detectedCity = city
                completion(city)
            }
        }
    }

    func advanceToConversation() {
        HapticManager.shared.impact(.medium)
        withAnimation(VennAnimation.gentle) {
            phase = .conversation
        }
        Task { await startConversation(city: detectedCity) }
    }

    func joinWaitlist(userCoordinate: CLLocationCoordinate2D? = nil) {
        guard !waitlistEmail.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        HapticManager.shared.success()
        // In production: send waitlistEmail + detectedCity + coordinate to backend

        // Add the user's location as a new heatmap dot
        if let coord = userCoordinate {
            withAnimation(VennAnimation.bouncy) {
                userHotspot = WaitlistHotspot(
                    city: detectedCity.isEmpty ? "You" : detectedCity,
                    coordinate: coord,
                    count: 1
                )
            }
        }

        withAnimation(VennAnimation.standard) {
            joinedWaitlist = true
        }
    }

    // MARK: - Conversation Phase

    func startConversation(city: String? = nil) async {
        isViviTyping = true

        let cityDisplay = city.flatMap { $0.isEmpty ? nil : $0 }

        if Self.useMockAPI {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            isViviTyping = false
            let opener: String
            if let c = cityDisplay {
                opener = "Hey! I'm Vivi, your social AI. I've already been scanning what's happening in \(c) — and there's a lot going on tonight. Let me learn a bit about you so I can find your perfect people and events. What do you usually do for fun?"
            } else {
                opener = "Hey! I'm Vivi, your social AI. I've already been scanning what's happening in your city — and there's a lot going on tonight. Let me learn a bit about you so I can find your perfect people and events. What do you usually do for fun?"
            }
            withAnimation(VennAnimation.standard) {
                messages.append(ChatMessage(content: opener, isUser: false))
                quickReplies = [
                    "Going out to eat & drink",
                    "Live music & nightlife",
                    "Outdoor adventures",
                    "Chill hangouts at home",
                ]
            }
            return
        }

        do {
            let response = try await networkClient.request(
                .startAIOnboarding(city: cityDisplay),
                as: OnboardingStartResponse.self
            )
            conversationId = response.conversationId
            lastInsightCount = response.insightsCount
            isViviTyping = false
            withAnimation(VennAnimation.standard) {
                messages.append(ChatMessage(content: response.message, isUser: false))
                quickReplies = suggestedReplies(exchangeIndex: 0)
            }
        } catch {
            #if DEBUG
            print("startOnboarding failed: \(error)")
            #endif
            isViviTyping = false
            withAnimation(VennAnimation.standard) {
                messages.append(ChatMessage(
                    content: "Hey! I'm Vivi. Tell me — what does a perfect week look like for you?",
                    isUser: false
                ))
                quickReplies = ["Going out to eat & drink", "Live music & nightlife", "Outdoor adventures"]
            }
        }
    }

    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        withAnimation(VennAnimation.standard) {
            messages.append(ChatMessage(content: text, isUser: true))
            quickReplies = []
            userInput = ""
        }

        HapticManager.shared.impact(.light)
        try? await Task.sleep(nanoseconds: 300_000_000)
        isViviTyping = true

        if Self.useMockAPI {
            try? await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
            handleMockResponse()
            return
        }

        guard let convId = conversationId else {
            isViviTyping = false
            return
        }

        do {
            let response = try await networkClient.request(
                .sendOnboardingMessage(conversationId: convId, content: text, city: detectedCity.isEmpty ? nil : detectedCity),
                as: OnboardingMessageResponse.self
            )
            isViviTyping = false

            if response.insightsCount > lastInsightCount {
                appendInsightCard()
                lastInsightCount = response.insightsCount
            }

            if let coverage = response.coverage {
                withAnimation(VennAnimation.standard) {
                    understandingProgress = min(1.0, Double(coverage.observationCount) / 8.0)
                }
            }

            withAnimation(VennAnimation.standard) {
                messages.append(ChatMessage(content: response.message, isUser: false))
                let idx = messages.filter(\.isUser).count
                quickReplies = suggestedReplies(exchangeIndex: idx)
            }

            if response.isComplete {
                isConversationComplete = true
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                advanceToReveal()
            }
        } catch {
            #if DEBUG
            print("sendOnboardingMessage failed: \(error)")
            #endif
            isViviTyping = false
            withAnimation(VennAnimation.standard) {
                messages.append(ChatMessage(
                    content: "That's really cool! Tell me more about the kind of people you click with.",
                    isUser: false
                ))
                quickReplies = ["Adventurous types", "Chill & low-key", "Creative people"]
            }
        }
    }

    func skipConversation() async {
        HapticManager.shared.impact(.light)
        if let convId = conversationId, !Self.useMockAPI {
            _ = try? await networkClient.request(
                .skipOnboarding(conversationId: convId),
                as: OnboardingSkipResponse.self
            )
        }
        advanceToReveal()
    }

    // MARK: - Reveal Phase

    func advanceToReveal() {
        generatePersonality()
        withAnimation(VennAnimation.gentle) {
            phase = .reveal
        }
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            HapticManager.shared.success()
            withAnimation(VennAnimation.bouncy) {
                revealVisible = true
            }
        }
    }

    func finishOnboarding() async {
        HapticManager.shared.impact(.heavy)
        if !Self.useMockAPI {
            try? await networkClient.requestVoid(.completeOnboarding(intent: "strangers"))
        }
        authManager.completeOnboarding()
    }

    // MARK: - Private

    private func appendInsightCard() {
        let idx = insightCards.count % insightTemplates.count
        let template = insightTemplates[idx]
        let accent = insightAccents[idx % insightAccents.count]
        withAnimation(VennAnimation.bouncy) {
            insightCards.append(InsightCard(
                icon: template.icon,
                title: template.title,
                subtitle: template.subtitle,
                accent: accent
            ))
        }
        HapticManager.shared.impact(.medium)
    }

    private func generatePersonality() {
        let types: [PersonalityResult] = [
            PersonalityResult(
                type: "The Connector",
                icon: "link.circle.fill",
                summary: "You bridge worlds — your superpower is making strangers feel like old friends. People are naturally drawn to your warmth."
            ),
            PersonalityResult(
                type: "The Explorer",
                icon: "safari.fill",
                summary: "You chase the unknown. Every night is a chance to discover something new, and you pull others along for the ride."
            ),
            PersonalityResult(
                type: "The Curator",
                icon: "wand.and.stars",
                summary: "Quality over quantity, always. You craft experiences that people talk about for weeks."
            ),
            PersonalityResult(
                type: "The Catalyst",
                icon: "bolt.circle.fill",
                summary: "You bring the energy. When you walk in, the room shifts. People orbit around your magnetism."
            ),
            PersonalityResult(
                type: "The Navigator",
                icon: "location.north.circle.fill",
                summary: "You read the room like a map. You always know where the vibe is heading — and you get there first."
            ),
        ]
        let chosen = types.randomElement()!
        personalityType = chosen.type
        personalityIcon = chosen.icon
        personalitySummary = chosen.summary
        recommendedEventsCount = Int.random(in: 8...18)
        similarPeopleCount = Int.random(in: 30...85)
    }

    private func handleMockResponse() {
        isViviTyping = false
        let exchangeCount = messages.filter(\.isUser).count

        if exchangeCount >= 2 {
            appendInsightCard()
        }

        withAnimation(VennAnimation.standard) {
            understandingProgress = min(1.0, Double(exchangeCount) * 0.22)
        }

        let mockExchanges: [(response: String, replies: [String])] = [
            (
                "Love that! I can already see some great matches forming. Quick question — what's your ideal group size when you go out?",
                ["Small & intimate (3-5)", "A solid crew (6-10)", "The more the merrier!", "Just me and one friend"]
            ),
            (
                "Got it. There are \(Int.random(in: 30...60)) people in your area with a really similar vibe. What usually makes you say yes to plans?",
                ["The people going", "The venue or activity", "Spontaneous energy", "Good food is involved"]
            ),
            (
                "Interesting! There are actually \(Int.random(in: 5...12)) events this weekend that match your energy perfectly. One more — how do you feel about meeting new people?",
                ["I love it, bring it on", "I'm open but a little shy", "Depends on the setting"]
            ),
            (
                "I've got a really solid read on you now. You're going to love what I find. Ready to see your social DNA?",
                ["Show me!", "I'm so ready", "Let's see it"]
            ),
        ]

        let idx = min(max(0, exchangeCount - 1), mockExchanges.count - 1)
        let mock = mockExchanges[idx]

        withAnimation(VennAnimation.standard) {
            messages.append(ChatMessage(content: mock.response, isUser: false))
            quickReplies = mock.replies
        }

        if exchangeCount >= mockExchanges.count {
            isConversationComplete = true
            Task {
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                advanceToReveal()
            }
        }
    }

    private func suggestedReplies(exchangeIndex: Int) -> [String] {
        switch exchangeIndex {
        case 0: return ["Going out to eat & drink", "Live music & nightlife", "Outdoor adventures"]
        case 1: return ["Small intimate groups", "Big social events", "One-on-one hangouts"]
        case 2: return ["Meet new people", "Find cool events", "Both!"]
        default: return ["Tell me more!", "I'm ready"]
        }
    }
}
