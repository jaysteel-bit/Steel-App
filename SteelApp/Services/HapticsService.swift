// HapticsService.swift
// Steel by Exo — Haptic Feedback Service
//
// Provides tactile feedback for key interactions in the Steel app.
// Haptics are crucial for the premium feel — every tap, verification step,
// and profile reveal should feel physical and satisfying.
//
// Usage: Call HapticsService.shared.play(.nfcDetected) at interaction points.

import UIKit

// MARK: - HapticsService
class HapticsService {
    static let shared = HapticsService()

    private init() {}

    // MARK: - Haptic Types
    enum HapticType {
        case nfcDetected          // When NFC tag is read successfully — sharp "thunk"
        case pinDigitEntered      // Each PIN digit entered — soft tap
        case pinCorrect           // Verification success — celebratory pattern
        case pinIncorrect         // Wrong PIN — error buzz
        case profileRevealed      // Profile card appears — smooth double-tap
        case buttonTap            // Standard button press — light tap
        case connectionSaved      // Contact saved — success pattern
    }

    // MARK: - Play
    func play(_ type: HapticType) {
        switch type {
        case .nfcDetected:
            // Sharp impact — feels like the card "connected"
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred(intensity: 1.0)

        case .pinDigitEntered:
            // Light tap for each digit — like typing on a premium keyboard
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred(intensity: 0.7)

        case .pinCorrect:
            // Success notification — the "you're in" moment
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)

        case .pinIncorrect:
            // Error notification — shake feeling
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)

        case .profileRevealed:
            // Medium impact — profile "materializes"
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 0.9)

        case .buttonTap:
            // Standard selection feedback
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()

        case .connectionSaved:
            // Success notification
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }
    }
}
