import Foundation

/// Matches the backend UserData response from GET /user/profile/me
struct User: Codable, Identifiable {
    let id: String
    let phoneNumber: String
    let email: String?
    let isOnboarded: Bool
    let points: Int?
    let profile: UserProfile
    let preferences: UserPreferences?

    // Computed properties
    var displayName: String {
        profile.Name ?? "User"
    }

    var hasCompletedOnboarding: Bool {
        isOnboarded
    }

    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber = "phone_number"
        case email
        case isOnboarded = "is_onboarded"
        case points
        case profile
        case preferences
    }
}

/// Backend Profile struct — fields without json tags serialize as PascalCase
struct UserProfile: Codable {
    let Name: String?
    let DateOfBirth: String?
    let Age: Int?
    let Gender: String?
    let GenderPreferences: [String]?
    let City: String?
    let Latitude: Double?
    let Longitude: Double?
    let Hometown: String?
    let IsOnboarded: Bool?
    let Interests: [String]?
    let LookingFor: [String]?

    let introExtrovert: String?
    let socialBattery: String?
    let politicalLeaning: String?
    let meetingPreferences: [String]?
    let groupRole: String?
    let socialStyles: [String]?
    let conversationPreferences: [String]?
    let connectionGoals: [String]?
    let preferredExperiences: [String]?
    let onboardingIntent: String?
    let instagramUsername: String?
    let linkedinUrl: String?

    enum CodingKeys: String, CodingKey {
        case Name, DateOfBirth, Age, Gender, GenderPreferences
        case City, Latitude, Longitude, Hometown, IsOnboarded
        case Interests, LookingFor
        case introExtrovert = "intro_extrovert"
        case socialBattery = "social_battery"
        case politicalLeaning = "political_leaning"
        case meetingPreferences = "meeting_preferences"
        case groupRole = "group_role"
        case socialStyles = "social_styles"
        case conversationPreferences = "conversation_preferences"
        case connectionGoals = "connection_goals"
        case preferredExperiences = "preferred_experiences"
        case onboardingIntent = "onboarding_intent"
        case instagramUsername = "instagram_username"
        case linkedinUrl = "linkedin_url"
    }
}

struct UserPreferences: Codable {
    let EmailNotifications: Bool?
    let PushNotifications: Bool?
    let MatchWith: String?
}

struct UpdateProfileRequest: Codable {
    var name: String?
    var dateOfBirth: String?
    var gender: String?
    var city: String?
    var interests: [String]?
    var lookingFor: [String]?

    enum CodingKeys: String, CodingKey {
        case name
        case dateOfBirth = "date_of_birth"
        case gender
        case city
        case interests
        case lookingFor = "looking_for"
    }
}
