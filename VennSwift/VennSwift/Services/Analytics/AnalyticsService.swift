import Foundation

/// Analytics service for tracking user events
/// TODO: Integrate PostHog or Firebase Analytics
actor AnalyticsService {
    static let shared = AnalyticsService()
    
    private var isConfigured = false
    
    private init() {}
    
    // MARK: - Configuration
    
    func configure() {
        guard !isConfigured else { return }
        
        #if DEBUG
        print("📊 Analytics: Configured (Debug Mode - Events Not Sent)")
        #else
        // TODO: Initialize PostHog or Firebase
        print("📊 Analytics: Configured")
        #endif
        
        isConfigured = true
    }
    
    // MARK: - Track Events
    
    func track(event: Event, properties: [String: Any]? = nil) {
        #if DEBUG
        print("📊 Analytics Event: \(event.rawValue)")
        if let props = properties {
            print("   Properties: \(props)")
        }
        #else
        // TODO: Send to analytics backend
        #endif
    }
    
    // MARK: - Screen Views
    
    func screenView(_ screen: String) {
        track(event: .screenView, properties: ["screen": screen])
    }
    
    // MARK: - User Properties
    
    func setUserProperties(_ properties: [String: Any]) {
        #if DEBUG
        print("📊 Analytics: Set User Properties: \(properties)")
        #else
        // TODO: Send to analytics backend
        #endif
    }
    
    func setUserId(_ userId: String) {
        #if DEBUG
        print("📊 Analytics: Set User ID: \(userId)")
        #else
        // TODO: Send to analytics backend
        #endif
    }
}

// MARK: - Event Enum

extension AnalyticsService {
    enum Event: String {
        // Auth
        case loginStarted = "login_started"
        case loginCompleted = "login_completed"
        case logoutCompleted = "logout_completed"
        
        // Onboarding
        case onboardingStarted = "onboarding_started"
        case onboardingStepCompleted = "onboarding_step_completed"
        case onboardingCompleted = "onboarding_completed"
        
        // Events
        case eventViewed = "event_viewed"
        case eventRSVP = "event_rsvp"
        case eventCreated = "event_created"
        
        // Friends
        case friendRequestSent = "friend_request_sent"
        case friendRequestAccepted = "friend_request_accepted"
        
        // Profile
        case profileUpdated = "profile_updated"
        case profilePhotoAdded = "profile_photo_added"
        
        // Generic
        case screenView = "screen_view"
        case buttonTapped = "button_tapped"
        case errorOccurred = "error_occurred"
    }
}
