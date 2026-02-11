// AuthService.swift
// Steel by Exo — Authentication Service (Clerk Auth Stub)
//
// Handles user authentication for the Steel app.
// In production, this integrates with Clerk (https://clerk.com)
// for social login, email/password, and invitation-based onboarding.
//
// Steel is invitation-only, so the auth flow includes:
//   1. Enter invite code (or get invited by existing member)
//   2. Create account (email, social login, or phone)
//   3. Set up profile (name, photo, headline, socials)
//   4. Get Steel digital membership immediately
//
// TODO: Replace with real Clerk SDK integration
// Clerk iOS SDK: https://clerk.com/docs/quickstarts/ios

import Foundation

// MARK: - AuthService
class AuthService: ObservableObject {

    @Published var isAuthenticated: Bool = false
    @Published var currentUserId: String? = nil

    private let simulateMode: Bool

    init(simulateMode: Bool = true) {
        self.simulateMode = simulateMode
    }

    // MARK: - Validate Invite Code
    /// Checks if an invite code is valid.
    /// Steel is invitation-only — new members need a code from an existing member
    /// or from Steel's internal team.
    func validateInviteCode(_ code: String) async throws -> Bool {
        if simulateMode {
            try await Task.sleep(nanoseconds: 500_000_000)
            // Accept any 6+ character code in dev mode
            return code.count >= 6
        }

        // TODO: POST /api/auth/validate-invite { "code": "..." }
        return false
    }

    // MARK: - Sign Up
    /// Creates a new Steel member account after invite validation.
    func signUp(email: String, password: String, inviteCode: String) async throws -> String {
        if simulateMode {
            try await Task.sleep(nanoseconds: 800_000_000)
            let userId = "steel_\(UUID().uuidString.prefix(8))"
            await MainActor.run {
                self.currentUserId = userId
                self.isAuthenticated = true
            }
            return userId
        }

        // TODO: Clerk SDK signUp call
        throw AuthServiceError.notImplemented
    }

    // MARK: - Sign In
    /// Signs in an existing Steel member.
    func signIn(email: String, password: String) async throws -> String {
        if simulateMode {
            try await Task.sleep(nanoseconds: 600_000_000)
            let userId = "steel_001"  // Mock user
            await MainActor.run {
                self.currentUserId = userId
                self.isAuthenticated = true
            }
            return userId
        }

        // TODO: Clerk SDK signIn call
        throw AuthServiceError.notImplemented
    }

    // MARK: - Sign Out
    func signOut() async {
        await MainActor.run {
            self.currentUserId = nil
            self.isAuthenticated = false
        }
    }
}

// MARK: - AuthServiceError
enum AuthServiceError: LocalizedError {
    case invalidInviteCode
    case invalidCredentials
    case accountExists
    case notImplemented

    var errorDescription: String? {
        switch self {
        case .invalidInviteCode: return "Invalid invite code."
        case .invalidCredentials: return "Invalid email or password."
        case .accountExists: return "An account with this email already exists."
        case .notImplemented: return "Auth not yet connected. Using simulate mode."
        }
    }
}
