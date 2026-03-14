import Foundation

/// API Client - Handles all network requests to venn-ai-backend
/// Features: Type-safe endpoints, error handling, retry logic, caching
@MainActor
class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    @Published var isOnline = true
    
    init(baseURL: String = "http://localhost:4000") {
        self.baseURL = baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Events API
    
    func fetchEvents(city: String = "sf", limit: Int = 20) async throws -> [DiscoverEvent] {
        let endpoint = "/api/events?city=\(city)&limit=\(limit)"
        let response: EventsResponse = try await request(endpoint: endpoint, method: "GET")
        return response.events.map { $0.toDiscoverEvent() }
    }
    
    func fetchEvent(id: String) async throws -> DiscoverEvent {
        let endpoint = "/api/events/\(id)"
        let response: EventDetailResponse = try await request(endpoint: endpoint, method: "GET")
        return response.event.toDiscoverEvent()
    }
    
    func scrapeEvents(sources: [String] = ["eventbrite", "luma"]) async throws -> ScrapeResponse {
        let endpoint = "/api/events/scrape"
        let body = ScrapeRequest(sources: sources)
        return try await request(endpoint: endpoint, method: "POST", body: body)
    }
    
    // MARK: - Vivi Chat API
    
    func sendViviMessage(_ message: String, conversationId: String? = nil) async throws -> ViviResponse {
        let endpoint = "/api/vivi/chat"
        let body = ViviRequest(message: message, conversationId: conversationId)
        return try await request(endpoint: endpoint, method: "POST", body: body)
    }
    
    // MARK: - User Preferences API
    
    func savePreferences(_ preferences: UserPreferences) async throws {
        let endpoint = "/api/preferences"
        let _: EmptyResponse = try await request(endpoint: endpoint, method: "POST", body: preferences)
    }
    
    func getPreferences() async throws -> UserPreferences {
        let endpoint = "/api/preferences"
        return try await request(endpoint: endpoint, method: "GET")
    }
    
    // MARK: - Event Interactions API
    
    func trackInteraction(_ interaction: EventInteraction) async throws {
        let endpoint = "/api/interactions"
        let _: EmptyResponse = try await request(endpoint: endpoint, method: "POST", body: interaction)
    }
    
    // MARK: - Health Check
    
    func checkHealth() async throws -> HealthResponse {
        let endpoint = "/health"
        return try await request(endpoint: endpoint, method: "GET")
    }
    
    // MARK: - Generic Request
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        body: (any Encodable)? = nil,
        retryCount: Int = 3
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        for attempt in 0..<retryCount {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                // Update online status
                await MainActor.run {
                    isOnline = true
                }
                
                // Handle status codes
                switch httpResponse.statusCode {
                case 200...299:
                    // Success - decode response
                    if T.self == EmptyResponse.self {
                        return EmptyResponse() as! T
                    }
                    return try decoder.decode(T.self, from: data)
                    
                case 400:
                    throw APIError.badRequest(message: parseErrorMessage(from: data))
                case 401:
                    throw APIError.unauthorized
                case 404:
                    throw APIError.notFound
                case 429:
                    throw APIError.rateLimited
                case 500...599:
                    throw APIError.serverError(code: httpResponse.statusCode)
                default:
                    throw APIError.unknown(statusCode: httpResponse.statusCode)
                }
                
            } catch let error as APIError {
                // Don't retry client errors
                if case .badRequest = error { throw error }
                if case .unauthorized = error { throw error }
                if case .notFound = error { throw error }
                
                // Retry server errors
                if attempt < retryCount - 1 {
                    let delay = Double(attempt + 1) * 0.5
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    throw error
                }
                
            } catch {
                // Network errors - mark offline
                await MainActor.run {
                    isOnline = false
                }
                
                if attempt < retryCount - 1 {
                    let delay = Double(attempt + 1) * 0.5
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    throw APIError.networkError(error)
                }
            }
        }
        
        throw APIError.unknown(statusCode: 0)
    }
    
    private func parseErrorMessage(from data: Data) -> String {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["error"] as? String {
            return message
        }
        return "Unknown error"
    }
}

// MARK: - API Models

struct EventsResponse: Codable {
    let events: [EventDTO]
    let count: Int
}

struct EventDetailResponse: Codable {
    let event: EventDTO
}

struct EventDTO: Codable {
    let id: String
    let name: String
    let description: String?
    let startTime: Date
    let endTime: Date?
    let location: String
    let imageUrl: String?
    let price: Double?
    let source: String
    let externalId: String
    let url: String
    
    func toDiscoverEvent() -> DiscoverEvent {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let dateFormatted = formatter.string(from: startTime)
        
        return DiscoverEvent(
            id: id,
            name: name,
            dateFormatted: dateFormatted,
            locationShort: extractLocationShort(from: location),
            imageUrl: imageUrl,
            attendees: nil,
            isFeatured: false
        )
    }
    
    private func extractLocationShort(from location: String) -> String {
        // Extract venue name or city from full location
        let components = location.components(separatedBy: ",")
        return components.first?.trimmingCharacters(in: .whitespaces) ?? location
    }
}

struct ScrapeRequest: Encodable {
    let sources: [String]
}

struct ScrapeResponse: Codable {
    let success: Bool
    let eventsScraped: Int
    let sources: [String]
}

struct ViviRequest: Encodable {
    let message: String
    let conversationId: String?
}

struct ViviResponse: Codable {
    let response: String
    let conversationId: String
    let eventRecommendations: [String]?
}

struct UserPreferences: Codable {
    let interests: [String]
    let vibes: [String]
    let joyTriggers: [String]
    let avoidances: [String]?
}

struct EventInteraction: Encodable {
    let eventId: String
    let action: String // "view", "click", "save", "rsvp", "skip"
    let timestamp: Date
}

struct HealthResponse: Codable {
    let status: String
    let timestamp: Date
    let version: String?
}

struct EmptyResponse: Codable {
    init() {}
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest(message: String)
    case unauthorized
    case notFound
    case rateLimited
    case serverError(code: Int)
    case networkError(Error)
    case unknown(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .unauthorized:
            return "Unauthorized"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError(let code):
            return "Server error (\(code))"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let statusCode):
            return "Unknown error (status: \(statusCode))"
        }
    }
}

// MARK: - Encodable Extension

extension Encodable {
    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}
