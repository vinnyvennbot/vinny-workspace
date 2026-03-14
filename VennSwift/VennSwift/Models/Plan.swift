import Foundation

struct Plan: Codable, Identifiable {
    let id: String
    let creatorId: String
    let title: String
    let description: String?
    let location: String?
    let latitude: Double?
    let longitude: Double?
    let startTime: Date
    let endTime: Date?
    let maxAttendees: Int?
    let isPublic: Bool
    let photos: [String]
    let attendees: [String]
    let invitedUsers: [String]
    let status: Status
    let createdAt: Date
    let updatedAt: Date
    
    enum Status: String, Codable {
        case draft
        case active
        case cancelled
        case completed
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId = "creator_id"
        case title
        case description
        case location
        case latitude
        case longitude
        case startTime = "start_time"
        case endTime = "end_time"
        case maxAttendees = "max_attendees"
        case isPublic = "is_public"
        case photos
        case attendees
        case invitedUsers = "invited_users"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Create Plan Request

struct CreatePlanRequest: Codable {
    let title: String
    let description: String?
    let location: String?
    let latitude: Double?
    let longitude: Double?
    let startTime: Date
    let endTime: Date?
    let maxAttendees: Int?
    let isPublic: Bool
    let invitedUserIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case location
        case latitude
        case longitude
        case startTime = "start_time"
        case endTime = "end_time"
        case maxAttendees = "max_attendees"
        case isPublic = "is_public"
        case invitedUserIds = "invited_user_ids"
    }
}
