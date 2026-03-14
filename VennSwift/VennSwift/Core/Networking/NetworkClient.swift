import Foundation

/// Modern async/await network client with automatic token refresh
actor NetworkClient {
    static let shared = NetworkClient()
    
    private let baseURL: URL
    private let session: URLSession
    private var accessToken: String?
    private var refreshToken: String?
    
    // Track ongoing refresh to prevent concurrent refresh requests
    private var refreshTask: Task<Void, Error>?
    
    private init() {
        // TODO: Use environment-based URL
        self.baseURL = URL(string: "https://api.vennsocial.co/api/staging")!
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
        
        // Load tokens from keychain
        Task {
            await loadTokens()
        }
    }
    
    // MARK: - Token Management
    
    func setTokens(access: String, refresh: String) async {
        self.accessToken = access
        self.refreshToken = refresh
        await KeychainService.shared.saveTokens(access: access, refresh: refresh)
    }
    
    func clearTokens() async {
        self.accessToken = nil
        self.refreshToken = nil
        await KeychainService.shared.clearTokens()
    }
    
    private func loadTokens() async {
        let tokens = await KeychainService.shared.getTokens()
        self.accessToken = tokens.access
        self.refreshToken = tokens.refresh
    }
    
    // MARK: - Request Execution
    
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        as type: T.Type
    ) async throws -> T {
        let request = try await buildRequest(for: endpoint)

        do {
            return try await execute(request, as: type)
        } catch NetworkError.unauthorized {
            try await refreshAccessToken()
            let retryRequest = try await buildRequest(for: endpoint)
            return try await execute(retryRequest, as: type)
        }
    }

    func requestVoid(_ endpoint: APIEndpoint) async throws {
        let request = try await buildRequest(for: endpoint)

        do {
            try await executeVoid(request)
        } catch NetworkError.unauthorized {
            try await refreshAccessToken()
            let retryRequest = try await buildRequest(for: endpoint)
            try await executeVoid(retryRequest)
        }
    }

    private func execute<T: Decodable>(
        _ request: URLRequest,
        as type: T.Type
    ) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        #if DEBUG
        print("[\(request.httpMethod ?? "GET")] \(request.url?.absoluteString ?? "")")
        print("Status: \(httpResponse.statusCode)")
        if let body = String(data: data, encoding: .utf8) {
            print("Body: \(body.prefix(500))")
        }
        #endif

        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(type, from: data)
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.clientError(httpResponse.statusCode)
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknown
        }
    }

    private func executeVoid(_ request: URLRequest) async throws {
        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        #if DEBUG
        print("[\(request.httpMethod ?? "GET")] \(request.url?.absoluteString ?? "")")
        print("Status: \(httpResponse.statusCode)")
        #endif

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.clientError(httpResponse.statusCode)
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknown
        }
    }
    
    // MARK: - Token Refresh
    
    private func refreshAccessToken() async throws {
        // If already refreshing, wait for that task
        if let existingTask = refreshTask {
            try await existingTask.value
            return
        }
        
        let task = Task<Void, Error> {
            guard let refreshToken = self.refreshToken else {
                throw NetworkError.noRefreshToken
            }
            
            let endpoint = APIEndpoint.refreshToken(refreshToken: refreshToken)
            let request = try await buildRequest(for: endpoint, includeAuth: false)
            
            let response: AuthResponse = try await execute(request, as: AuthResponse.self)
            await setTokens(access: response.accessToken, refresh: response.refreshToken)
        }
        
        self.refreshTask = task
        
        do {
            try await task.value
            self.refreshTask = nil
        } catch {
            self.refreshTask = nil
            await clearTokens()
            throw error
        }
    }
    
    // MARK: - Request Building
    
    private func buildRequest(
        for endpoint: APIEndpoint,
        includeAuth: Bool = true
    ) async throws -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        // Add authorization if available
        if includeAuth, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if present
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return request
    }
}

// MARK: - API Endpoint Definition

enum APIEndpoint {
    case requestOTP(phoneNumber: String)
    case verifyOTP(phoneNumber: String, otp: String)
    case refreshToken(refreshToken: String)
    case logout(refreshToken: String)
    case getCurrentUser
    case updateProfile(UpdateProfileRequest)
    case getEvents
    case createPlan(CreatePlanRequest)
    /// AI-personalized discovery feed — returns friend invites + recommended stranger plans
    case getForYouFeed

    // MARK: AI Onboarding Agent
    case startAIOnboarding(city: String?)
    case sendOnboardingMessage(conversationId: String, content: String, city: String?)
    case skipOnboarding(conversationId: String)
    case getOnboardingStatus
    case completeOnboarding(intent: String)

    var path: String {
        switch self {
        case .requestOTP: return "/auth/request_otp"
        case .verifyOTP: return "/auth/verify_otp"
        case .refreshToken: return "/auth/refresh_token"
        case .logout: return "/auth/logout"
        case .getCurrentUser: return "/user/profile/me"
        case .updateProfile: return "/user/profile"
        case .getEvents: return "/events"
        case .createPlan: return "/plans"
        case .getForYouFeed: return "/plans/for-you"
        case .startAIOnboarding: return "/ai/onboarding/start"
        case .sendOnboardingMessage(let id, _, _): return "/ai/onboarding/\(id)/message"
        case .skipOnboarding(let id): return "/ai/onboarding/\(id)/skip"
        case .getOnboardingStatus: return "/ai/onboarding/status"
        case .completeOnboarding: return "/user/onboarding/complete"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .requestOTP, .verifyOTP, .refreshToken, .logout, .createPlan,
             .startAIOnboarding, .sendOnboardingMessage, .skipOnboarding:
            return .post
        case .updateProfile, .completeOnboarding:
            return .put
        case .getCurrentUser, .getEvents, .getForYouFeed, .getOnboardingStatus:
            return .get
        }
    }

    var body: Encodable? {
        switch self {
        case .requestOTP(let phone):
            return ["phone_number": phone]
        case .verifyOTP(let phone, let otp):
            return ["phone_number": phone, "otp": otp]
        case .refreshToken(let token):
            return ["refresh_token": token]
        case .logout(let token):
            return ["refresh_token": token]
        case .updateProfile(let request):
            return request
        case .createPlan(let request):
            return request
        case .getCurrentUser, .getEvents, .getForYouFeed,
             .skipOnboarding, .getOnboardingStatus:
            return nil
        case .startAIOnboarding(let city):
            if let city { return ["city": city] }
            return nil
        case .sendOnboardingMessage(_, let content, let city):
            if let city { return ["content": content, "city": city] }
            return ["content": content]
        case .completeOnboarding(let intent):
            return ["intent": intent]
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case clientError(Int)
    case serverError(Int)
    case noRefreshToken
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Unauthorized - please login again"
        case .clientError(let code):
            return "Client error: \(code)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .noRefreshToken:
            return "No refresh token available"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
