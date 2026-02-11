// SteelTheme.swift
// Steel by Exo — Design System
//
// This is the single source of truth for Steel's visual identity.
// Every color, font, spacing, and effect constant lives here.
// Ported directly from the steel.html web prototype.
//
// Design Language:
// - Dark mode first (#050505 background)
// - Emerald accent (#10b981)
// - Glassmorphism (frosted glass cards)
// - Metallic text shimmers
// - Particle effects and ambient glow
// - Premium, cyber-luxury aesthetic

import SwiftUI

// MARK: - SteelTheme Namespace
// Use as: SteelTheme.Colors.background, SteelTheme.Fonts.headline, etc.
enum SteelTheme {

    // MARK: - Colors
    // Mapped directly from steel.html tailwind config:
    //   brand-black: '#050505'
    //   brand-dark:  '#0a0a0a'
    //   brand-gray:  '#1f1f1f'
    //   brand-text:  '#f5f5f5'
    //   brand-muted: '#a3a3a3'
    //   brand-accent: '#10b981' (Emerald)
    enum Colors {
        static let background  = Color(hex: 0x050505)   // Main app background
        static let surface     = Color(hex: 0x0A0A0A)   // Card/surface background
        static let surfaceAlt  = Color(hex: 0x1F1F1F)   // Elevated surface (PIN fields, inputs)
        static let text        = Color(hex: 0xF5F5F5)   // Primary text
        static let textMuted   = Color(hex: 0xA3A3A3)   // Secondary/muted text
        static let accent      = Color(hex: 0x10B981)   // Emerald green — primary accent
        static let accentLight = Color(hex: 0x34D399)   // Lighter emerald for hover/active states

        // Glass effect colors (from .glass CSS class)
        static let glassFill   = Color.white.opacity(0.05)
        static let glassBorder = Color.white.opacity(0.10)

        // Ambient glow — used for background radial gradients
        static let glowEmerald = Color(hex: 0x10B981).opacity(0.15)
    }

    // MARK: - Fonts
    // Maps to the Google Fonts used in the HTML prototype:
    //   sans: Inter (weights 300, 400, 500)
    //   serif: Playfair Display (weights 400, 600, italic)
    //
    // NOTE: To use custom fonts in iOS, add the .ttf/.otf files to the Xcode project
    // and register them in Info.plist under "Fonts provided by application".
    // For now, we use system fonts with similar weights as fallbacks.
    // When you add the actual font files, just update these references.
    enum Fonts {
        // Serif — used for headlines, names, "Tap to Connect"
        // Playfair Display equivalent: use .serif design
        static func serif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            // TODO: Replace with .custom("PlayfairDisplay-Regular", size: size) once font files are added
            return .system(size: size, weight: weight, design: .serif)
        }

        static func serifItalic(size: CGFloat) -> Font {
            // TODO: Replace with .custom("PlayfairDisplay-Italic", size: size) once font files are added
            return .system(size: size, weight: .regular, design: .serif).italic()
        }

        // Sans — used for body text, labels, buttons
        // Inter equivalent: use .default design
        static func sans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            // TODO: Replace with .custom("Inter-Regular", size: size) once font files are added
            return .system(size: size, weight: weight, design: .default)
        }

        // Pre-built text styles matching the HTML prototype
        static let heroTitle      = serif(size: 48, weight: .medium)       // h1 — "Access Redefined"
        static let cardName       = serifItalic(size: 36)                   // Profile name
        static let sectionTitle   = serif(size: 28, weight: .semibold)      // Section headers
        static let headline       = sans(size: 20, weight: .medium)         // Subheadings
        static let body           = sans(size: 16, weight: .regular)        // Body text
        static let bodyLight      = sans(size: 16, weight: .light)          // Light body (descriptions)
        static let caption        = sans(size: 14, weight: .regular)        // Captions
        static let captionMuted   = sans(size: 12, weight: .regular)        // Small muted text
        static let badge          = sans(size: 10, weight: .medium)         // Badge/tag text
        static let button         = sans(size: 14, weight: .medium)         // Button labels
    }

    // MARK: - Spacing
    // Consistent spacing scale used throughout the app
    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radii
    enum Radius {
        static let small:  CGFloat = 8    // Small elements (badges, inputs)
        static let medium: CGFloat = 12   // Cards, buttons
        static let large:  CGFloat = 24   // Phone screen container (rounded-3xl)
        static let pill:   CGFloat = 9999 // Fully rounded (pills, tags)
    }

    // MARK: - Animations
    // Timing curves and durations matching the GSAP timeline from the HTML
    enum Animation {
        static let quick     = SwiftUI.Animation.easeOut(duration: 0.3)
        static let standard  = SwiftUI.Animation.easeOut(duration: 0.6)
        static let slow      = SwiftUI.Animation.easeOut(duration: 0.8)
        static let reveal    = SwiftUI.Animation.easeInOut(duration: 1.2)

        // Spring animations for interactive elements (buttons, cards)
        static let spring    = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let bouncy    = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
}

// MARK: - Color Extension
// Hex color initializer for SwiftUI Color.
// Used throughout the theme to convert web hex values (#050505, etc.)
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8)  & 0xFF) / 255.0,
            blue:  Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
