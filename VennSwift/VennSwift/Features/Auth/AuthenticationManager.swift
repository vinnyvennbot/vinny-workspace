import Foundation
import SwiftUI

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()

    @Published private(set) var state: AuthState = .loading
    @Published private(set) var currentUser: User?

    private let networkClient = NetworkClient.shared

    private init() {}

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

    func checkAuthStatus() async {
        let tokens = await KeychainService.shared.getTokens()

        guard tokens.access != nil else {
            state = .unauthenticated
            return
        }

        do {
            let user = try await networkClient.request(
                .getCurrentUser,
                as: User.self
            )
            self.currentUser = user
            self.state = .authenticated(needsOnboarding: !user.hasCompletedOnboarding)
        } catch {
            #if DEBUG
            print("checkAuthStatus failed: \(error)")
            #endif
            await logout()
        }
    }

    func requestOTP(phoneNumber: String) async throws {
        try await networkClient.requestVoid(
            .requestOTP(phoneNumber: phoneNumber)
        )
    }

    func verifyOTP(phoneNumber: String, otp: String) async throws {
        let response = try await networkClient.request(
            .verifyOTP(phoneNumber: phoneNumber, otp: otp),
            as: AuthResponse.self
        )

        await networkClient.setTokens(
            access: response.accessToken,
            refresh: response.refreshToken
        )

        let user = try await networkClient.request(
            .getCurrentUser,
            as: User.self
        )

        self.currentUser = user
        self.state = .authenticated(needsOnboarding: !user.hasCompletedOnboarding)
    }

    func logout() async {
        let tokens = await KeychainService.shared.getTokens()
        if let refresh = tokens.refresh {
            try? await networkClient.requestVoid(
                .logout(refreshToken: refresh)
            )
        }

        await networkClient.clearTokens()
        self.currentUser = nil
        self.state = .unauthenticated
    }

    func completeOnboarding() {
        guard case .authenticated = state else { return }
        state = .authenticated(needsOnboarding: false)
    }
}

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

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct EmptyResponse: Decodable {}
