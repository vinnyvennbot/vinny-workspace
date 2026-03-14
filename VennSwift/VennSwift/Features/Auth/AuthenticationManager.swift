import Foundation
import SwiftUI

/// Central authentication manager using modern Swift concurrency
@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published private(set) var state: AuthState = .loading
    @Published private(set) var currentUser: User?
    
    private let networkClient = NetworkClient.shared
    
    private init() {}
    
    // MARK: - Auth State
    
    enum AuthState: Equatable {
        case loading
        case unauthenticated
        case authenticated(needsOnboarding: Bool)
        
        var isAuthenticated: Bool {
            if case .authenticated = self {
                return true
            }
            return false
        }
    }
    
    // MARK: - Check Auth Status
    
    func checkAuthStatus() async {
        // Check if we have tokens
        let tokens = await KeychainService.shared.getTokens()
        
        guard tokens.access != nil else {
            state = .unauthenticated
            return
        }
        
        // Verify tokens are valid by fetching current user
        do {
            let user = try await networkClient.request(
                .getCurrentUser,
                as: User.self
            )
            self.currentUser = user
            self.state = .authenticated(needsOnboarding: !user.hasCompletedOnboarding)
        } catch {
            // Token invalid - clear and show login
            await logout()
        }
    }
    
    // MARK: - OTP Flow
    
    func requestOTP(phoneNumber: String) async throws {
        struct OTPResponse: Decodable {
            let success: Bool
            let message: String?
        }
        
        let response = try await networkClient.request(
            .requestOTP(phoneNumber: phoneNumber),
            as: OTPResponse.self
        )
        
        if !response.success {
            throw AuthError.otpRequestFailed(response.message ?? "Unknown error")
        }
    }
    
    func verifyOTP(phoneNumber: String, otp: String) async throws {
        let response = try await networkClient.request(
            .verifyOTP(phoneNumber: phoneNumber, otp: otp),
            as: AuthResponse.self
        )
        
        // Save tokens
        await networkClient.setTokens(
            access: response.accessToken,
            refresh: response.refreshToken
        )
        
        // Fetch user profile
        let user = try await networkClient.request(
            .getCurrentUser,
            as: User.self
        )
        
        self.currentUser = user
        self.state = .authenticated(needsOnboarding: !user.hasCompletedOnboarding)
    }
    
    // MARK: - Logout
    
    func logout() async {
        // Attempt to notify backend (best effort - don't throw)
        let tokens = await KeychainService.shared.getTokens()
        if let refresh = tokens.refresh {
            try? await networkClient.request(
                .logout(refreshToken: refresh),
                as: EmptyResponse.self
            )
        }
        
        // Clear local state
        await networkClient.clearTokens()
        self.currentUser = nil
        self.state = .unauthenticated
    }
    
    // MARK: - Complete Onboarding
    
    func completeOnboarding() {
        guard case .authenticated = state else { return }
        state = .authenticated(needsOnboarding: false)
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case otpRequestFailed(String)
    case otpVerificationFailed
    case invalidPhoneNumber
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .otpRequestFailed(let message):
            return message
        case .otpVerificationFailed:
            return "Invalid verification code"
        case .invalidPhoneNumber:
            return "Please enter a valid phone number"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - API Response Models

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct EmptyResponse: Decodable {}
