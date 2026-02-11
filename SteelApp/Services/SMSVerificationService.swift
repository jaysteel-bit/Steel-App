// SMSVerificationService.swift
// Steel by Exo — SMS PIN Verification Service (Twilio Backend Stub)
//
// Handles the consent-based verification flow:
//   1. Receiver taps sharer's NFC tag → app reads sharer ID
//   2. App calls backend to send SMS PIN to sharer's phone
//   3. Sharer sees PIN on their phone (and an alert that someone is requesting access)
//   4. Receiver enters PIN → app verifies with backend
//   5. If correct → profile is revealed
//
// This ensures REAL-TIME CONSENT: the sharer must be physically present
// and aware that someone is requesting their profile. They can ignore
// the SMS (connection times out) or share the PIN to approve.
//
// BACKEND DEPENDENCY:
// This service calls the Node.js backend which wraps Twilio's SMS API.
// For development/testing, it can use a simulated mode that auto-generates
// a PIN locally without actually sending SMS.
//
// TODO: Replace with real backend URL and Twilio integration

import Foundation

// MARK: - SMSVerificationService
class SMSVerificationService: ObservableObject {

    // MARK: - Configuration
    // Base URL for the Steel backend API
    // TODO: Update this to your deployed backend URL
    private let baseURL: String

    // When true, skips real SMS and uses a hardcoded PIN ("1234") for development.
    // Set to false when you have the Twilio backend running.
    private let simulateMode: Bool

    // The simulated PIN used in development mode
    private let simulatedPIN = "1234"

    init(baseURL: String = "http://localhost:3000/api", simulateMode: Bool = true) {
        self.baseURL = baseURL
        self.simulateMode = simulateMode
    }

    // MARK: - Send Verification PIN
    /// Tells the backend to send an SMS PIN to the sharer's phone.
    /// The sharer gets a message like:
    ///   "Someone is requesting your Steel profile. Your PIN: 7293"
    ///   "If this wasn't you, ignore this message."
    ///
    /// - Parameter sharerId: The Steel member ID read from the NFC tag
    /// - Returns: A verification session ID to use when verifying the PIN
    func sendVerificationPIN(sharerId: String) async throws -> VerificationSession {
        // SIMULATE MODE: Skip the network call, return a fake session
        if simulateMode {
            // Simulate network delay (feels more realistic in demos)
            try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

            return VerificationSession(
                sessionId: UUID().uuidString,
                sharerId: sharerId,
                expiresAt: Date().addingTimeInterval(120),   // 2-minute expiry
                pinLength: 4,
                simulatedPIN: simulatedPIN                    // Only set in simulate mode
            )
        }

        // REAL MODE: Call the backend API
        // POST /api/sms/send-pin
        // Body: { "sharerId": "steel_001" }
        // Response: { "sessionId": "abc-123", "expiresAt": "2026-...", "pinLength": 4 }
        guard let url = URL(string: "\(baseURL)/sms/send-pin") else {
            throw VerificationServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["sharerId": sharerId])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw VerificationServiceError.serverError
        }

        let session = try JSONDecoder().decode(VerificationSession.self, from: data)
        return session
    }

    // MARK: - Verify PIN
    /// Checks whether the PIN entered by the receiver matches the one sent to the sharer.
    ///
    /// - Parameters:
    ///   - sessionId: The verification session ID from sendVerificationPIN
    ///   - pin: The 4-digit PIN entered by the receiver
    /// - Returns: True if PIN is correct, false otherwise
    func verifyPIN(sessionId: String, pin: String, simulatedPIN: String? = nil) async throws -> Bool {
        // SIMULATE MODE: Compare against hardcoded PIN
        if simulateMode {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            let expectedPIN = simulatedPIN ?? self.simulatedPIN
            return pin == expectedPIN
        }

        // REAL MODE: Call the backend API
        // POST /api/sms/verify-pin
        // Body: { "sessionId": "abc-123", "pin": "7293" }
        // Response: { "verified": true/false }
        guard let url = URL(string: "\(baseURL)/sms/verify-pin") else {
            throw VerificationServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["sessionId": sessionId, "pin": pin]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw VerificationServiceError.serverError
        }

        let result = try JSONDecoder().decode(VerifyPINResponse.self, from: data)
        return result.verified
    }
}

// MARK: - VerificationSession
// Returned by the backend when a verification PIN is sent.
struct VerificationSession: Codable {
    let sessionId: String
    let sharerId: String
    let expiresAt: Date
    let pinLength: Int
    var simulatedPIN: String?    // Only present in simulate mode (not sent to real backend)
}

// MARK: - VerifyPINResponse
struct VerifyPINResponse: Codable {
    let verified: Bool
}

// MARK: - VerificationServiceError
enum VerificationServiceError: LocalizedError {
    case invalidURL
    case serverError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:    return "Invalid server URL."
        case .serverError:   return "Server error. Please try again."
        case .decodingError: return "Unexpected server response."
        }
    }
}
