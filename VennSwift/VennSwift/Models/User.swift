import Foundation

struct User: Codable, Identifiable {
    let id: String
    let phoneNumber: String
    let firstName: String?
    let lastName: String?
    let birthday: Date?
    let gender: Gender?
    let city: String?
    let profilePhotos: [String]
    let bio: String?
    let hasCompletedOnboarding: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Computed properties
    var fullName: String? {
        guard let first = firstName, let last = lastName else {
            return firstName ?? lastName
        }
        return "\(first) \(last)"
    }
    
    var displayName: String {
        fullName ?? "User"
    }
    
    enum Gender: String, Codable {
        case male
        case female
        case nonBinary = "non_binary"
        case other
        case preferNotToSay = "prefer_not_to_say"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case birthday
        case gender
        case city
        case profilePhotos = "profile_photos"
        case bio
        case hasCompletedOnboarding = "has_completed_onboarding"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Update Profile Request

struct UpdateProfileRequest: Codable {
    let firstName: String?
    let lastName: String?
    let birthday: Date?
    let gender: User.Gender?
    let city: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case birthday
        case gender
        case city
        case bio
    }
}
