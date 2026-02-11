// ProfileService.swift
// Steel by Exo — Profile Data Service (Convex Backend Stub)
//
// Handles fetching and managing Steel member profiles.
// In production, this talks to a Convex backend for real-time profile storage.
// For now, it provides mock data so we can build and test the UI.
//
// PRIVACY GRADIENT:
// When fetching a profile after NFC tap, the service respects the privacy gradient:
//   - fetchPartialProfile(): Returns PUBLIC layer only (name, photo, headline)
//     Used before PIN verification — shows blurred photo and name teaser
//   - fetchFullProfile(): Returns all layers after successful PIN verification
//     Used after verification — shows everything the sharer has approved
//
// TODO: Replace mock implementations with real Convex client calls

import Foundation

// MARK: - ProfileService
class ProfileService: ObservableObject {

    // MARK: - Configuration
    private let baseURL: String
    private let simulateMode: Bool

    init(baseURL: String = "http://localhost:3000/api", simulateMode: Bool = true) {
        self.baseURL = baseURL
        self.simulateMode = simulateMode
    }

    // MARK: - Fetch Partial Profile (Pre-Verification)
    /// Fetches the PUBLIC layer of a member's profile.
    /// This is what shows during the verification step:
    ///   - Blurred/placeholder photo
    ///   - First name only
    ///   - Membership tier badge
    ///
    /// This gives the receiver a preview of WHO they're connecting with
    /// before the sharer approves via PIN.
    func fetchPartialProfile(memberId: String) async throws -> SteelProfile {
        if simulateMode {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
            // Return mock profile with partial data
            return SteelProfile.mock
        }

        // REAL MODE:
        // GET /api/profiles/{memberId}?level=public
        guard let url = URL(string: "\(baseURL)/profiles/\(memberId)?level=public") else {
            throw ProfileServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProfileServiceError.serverError
        }

        return try JSONDecoder().decode(SteelProfile.self, from: data)
    }

    // MARK: - Fetch Full Profile (Post-Verification)
    /// Fetches the FULL profile after PIN verification succeeds.
    /// Includes all layers the sharer has approved for sharing:
    ///   - Full name, photo, bio
    ///   - All social links
    ///   - Contact info (if approved)
    ///
    /// Requires a valid verification session token.
    func fetchFullProfile(memberId: String, verificationSessionId: String) async throws -> SteelProfile {
        if simulateMode {
            try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
            return SteelProfile.mock
        }

        // REAL MODE:
        // GET /api/profiles/{memberId}?level=full&session={sessionId}
        guard let url = URL(string: "\(baseURL)/profiles/\(memberId)?level=full&session=\(verificationSessionId)") else {
            throw ProfileServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProfileServiceError.serverError
        }

        return try JSONDecoder().decode(SteelProfile.self, from: data)
    }

    // MARK: - Update Profile
    /// Updates the current user's own profile.
    /// Used in settings/profile editing screens.
    func updateProfile(_ profile: SteelProfile) async throws {
        if simulateMode {
            try await Task.sleep(nanoseconds: 300_000_000)
            return // Simulate success
        }

        // REAL MODE:
        // PUT /api/profiles/{memberId}
        guard let url = URL(string: "\(baseURL)/profiles/\(profile.id)") else {
            throw ProfileServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(profile)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProfileServiceError.serverError
        }
    }
}

// MARK: - ProfileServiceError
enum ProfileServiceError: LocalizedError {
    case invalidURL
    case serverError
    case notFound
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:     return "Invalid server URL."
        case .serverError:    return "Server error. Please try again."
        case .notFound:       return "Profile not found."
        case .unauthorized:   return "Not authorized to view this profile."
        }
    }
}
