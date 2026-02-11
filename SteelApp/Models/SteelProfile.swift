// SteelProfile.swift
// Steel by Exo — User Profile Model
//
// Represents a Steel member's profile data.
// This model maps to the profile card shown in steel.html after verification:
//   - Photo, name, headline, member status
//   - Social links (Instagram, LinkedIn, phone, etc.)
//   - Privacy gradient: PUBLIC layer vs PRIVATE layer
//
// The privacy gradient is core to Steel's value prop:
//   PUBLIC:  Name, photo, headline, membership status (shared on tap)
//   PRIVATE: Phone, email, personal socials (requires approval)

import Foundation

// MARK: - SteelProfile
struct SteelProfile: Identifiable, Codable, Equatable {
    let id: String                          // Unique member ID (stored on NFC tag)
    var firstName: String
    var lastName: String
    var headline: String                    // e.g. "Creative Director | NYC"
    var bio: String?
    var avatarURL: String?                  // URL to profile photo
    var membershipTier: MembershipTier

    // MARK: - Public Layer (shared immediately on NFC tap)
    var publicSocials: [SocialLink]         // Links visible to anyone after verification

    // MARK: - Private Layer (requires explicit approval to share)
    var phoneNumber: String?
    var email: String?
    var privateSocials: [SocialLink]        // Links only shared after connection approval

    // MARK: - Computed
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var displayName: String {
        // In the HTML prototype this shows as "Alex Rivera"
        fullName
    }
}

// MARK: - MembershipTier
// Maps to the tier system from the product docs.
// For MVP, we start with one tier and expand later.
enum MembershipTier: String, Codable, Equatable {
    case digital  = "digital"       // Digital-only membership
    case steel    = "steel"         // Physical card holder
    case elite    = "elite"         // Wearable + premium perks

    var displayName: String {
        switch self {
        case .digital: return "Steel Digital"
        case .steel:   return "Steel Member"
        case .elite:   return "Steel Elite"
        }
    }
}

// MARK: - SocialLink
// Represents a single social media or contact link.
// The HTML prototype shows Instagram, LinkedIn, and Phone as the three columns.
struct SocialLink: Identifiable, Codable, Equatable {
    let id: String
    var platform: SocialPlatform
    var handle: String                      // e.g. "@alex.rivera"
    var url: String?                        // Full URL if applicable

    init(id: String = UUID().uuidString, platform: SocialPlatform, handle: String, url: String? = nil) {
        self.id = id
        self.platform = platform
        self.handle = handle
        self.url = url
    }
}

// MARK: - SocialPlatform
// Supported social platforms. We'll expand this as needed.
// Maps to the lucide icons used in the HTML (instagram, linkedin, phone)
enum SocialPlatform: String, Codable, Equatable {
    case instagram  = "instagram"
    case linkedin   = "linkedin"
    case twitter    = "twitter"
    case phone      = "phone"
    case email      = "email"
    case website    = "website"

    // SF Symbol name for each platform
    // (In the HTML these are lucide icons; in iOS we use SF Symbols)
    var iconName: String {
        switch self {
        case .instagram: return "camera.fill"           // Closest SF Symbol
        case .linkedin:  return "briefcase.fill"
        case .twitter:   return "bird.fill"
        case .phone:     return "phone.fill"
        case .email:     return "envelope.fill"
        case .website:   return "globe"
        }
    }

    var displayName: String {
        switch self {
        case .instagram: return "Instagram"
        case .linkedin:  return "LinkedIn"
        case .twitter:   return "Twitter"
        case .phone:     return "Contact"
        case .email:     return "Email"
        case .website:   return "Website"
        }
    }
}

// MARK: - Mock Data
// Used for SwiftUI previews and development — matches the HTML prototype's "Alex Rivera"
extension SteelProfile {
    static let mock = SteelProfile(
        id: "steel_001",
        firstName: "Alex",
        lastName: "Rivera",
        headline: "Creative Director | NYC",
        bio: "Building the future of digital identity and curated experiences.",
        avatarURL: "https://randomuser.me/api/portraits/men/32.jpg",
        membershipTier: .steel,
        publicSocials: [
            SocialLink(platform: .instagram, handle: "@alex.rivera"),
            SocialLink(platform: .linkedin, handle: "LinkedIn"),
            SocialLink(platform: .phone, handle: "Contact"),
        ],
        phoneNumber: "+1 (555) 123-4567",
        email: "alex@exo.dev",
        privateSocials: [
            SocialLink(platform: .twitter, handle: "@alexr_creates"),
        ]
    )
}
