// SteelConnection.swift
// Steel by Exo — Connection Model
//
// Represents a connection between two Steel members initiated via NFC tap.
// This is the core of the social sharing flow:
//   TAP → INSTANT PROFILE VIEW → APPROVAL/REJECTION → NATIVE SAVE
//
// Connections have a privacy gradient:
//   - PUBLIC layer shared immediately after PIN verification
//   - PRIVATE layer requires explicit approval from the sharer
//
// The sharer always stays in control — they can revoke at any time.

import Foundation

// MARK: - SteelConnection
struct SteelConnection: Identifiable, Codable, Equatable {
    let id: String
    let sharerId: String                    // The member who shared their profile (via NFC tag)
    let receiverId: String                  // The member who tapped / received the profile
    var status: ConnectionStatus
    var privacyLevel: PrivacyLevel          // What level of info has been shared
    let createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        sharerId: String,
        receiverId: String,
        status: ConnectionStatus = .pendingVerification,
        privacyLevel: PrivacyLevel = .public_,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.sharerId = sharerId
        self.receiverId = receiverId
        self.status = status
        self.privacyLevel = privacyLevel
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - ConnectionStatus
// The lifecycle of a connection, matching the HTML flow:
//   Tap → Verification (PIN) → Profile Revealed → Connected (or Rejected/Revoked)
enum ConnectionStatus: String, Codable, Equatable {
    case pendingVerification = "pending_verification"   // NFC tap detected, waiting for PIN
    case verifying           = "verifying"              // PIN entered, checking with backend
    case verified            = "verified"               // PIN correct, profile revealed
    case connected           = "connected"              // Both parties confirmed
    case rejected            = "rejected"               // Sharer declined the connection
    case revoked             = "revoked"                // Sharer revoked after initial share
    case expired             = "expired"                // Verification timed out
}

// MARK: - PrivacyLevel
// Matches the "Privacy Gradient Design" from the product docs:
//   PUBLIC LAYER:  Name, photo, headline, membership status
//   PRIVATE LAYER: Phone, email, personal socials, detailed info
enum PrivacyLevel: String, Codable, Equatable {
    case public_     = "public"             // Only public layer visible
    case full        = "full"               // All layers visible (approved by sharer)
    case custom      = "custom"             // Sharer chose specific fields to share
}
