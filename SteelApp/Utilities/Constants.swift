// Constants.swift
// Steel by Exo — App-Wide Constants
//
// Centralized configuration values, API endpoints, and feature flags.
// Keep all magic strings and numbers here to avoid scattering them through the codebase.
// This makes it easy to swap endpoints, toggle features, and configure the app
// for different environments (dev, staging, production).

import Foundation

enum SteelConstants {

    // MARK: - API Endpoints
    // TODO: Update these when deploying to production
    enum API {
        static let baseURL = "http://localhost:3000/api"

        // Auth endpoints (Clerk)
        static let validateInvite = "\(baseURL)/auth/validate-invite"
        static let signUp         = "\(baseURL)/auth/signup"
        static let signIn         = "\(baseURL)/auth/signin"

        // SMS Verification endpoints (Twilio)
        static let sendPIN        = "\(baseURL)/sms/send-pin"
        static let verifyPIN      = "\(baseURL)/sms/verify-pin"

        // Profile endpoints (Convex)
        static let profiles       = "\(baseURL)/profiles"
    }

    // MARK: - NFC Configuration
    enum NFC {
        // The base URL written to NFC tags for web fallback
        // When a non-member taps, their phone opens this URL
        static let fallbackBaseURL = "https://steel.byexo.com/connect"

        // Custom NDEF external type identifier
        // This is how the Steel app recognizes its own NFC tags
        static let externalType = "com.exo.steel:connect"

        // Current NDEF record version
        static let recordVersion = "1.0"
    }

    // MARK: - Verification
    enum Verification {
        // PIN length (number of digits)
        static let pinLength = 4

        // How long a verification session lasts before expiring
        static let sessionTimeoutSeconds: TimeInterval = 120  // 2 minutes

        // How long the scan line animation plays during verification
        static let scanAnimationDuration: TimeInterval = 1.2
    }

    // MARK: - Feature Flags
    // Toggle features on/off during development.
    // TODO: Replace with remote config (LaunchDarkly, Firebase, etc.) in production
    enum Features {
        // Use simulated NFC/SMS instead of real backend calls
        static let simulateMode = true

        // Show the "Scan Real Tag" button in the tap screen
        static let showRealNFCButton = true

        // Enable haptic feedback
        static let hapticsEnabled = true

        // Enable background particles (can disable for performance testing)
        static let particlesEnabled = true
    }

    // MARK: - App Info
    enum App {
        static let name = "Steel by Exo"
        static let tagline = "Access Redefined."
        static let bundleId = "com.exo.steel"
        static let deepLinkScheme = "steel"
    }
}
