// VerificationViewModel.swift
// Steel by Exo — Verification Flow ViewModel
//
// Orchestrates the entire NFC tap → PIN verification → profile reveal flow.
// This is the "brain" behind the three-state transition shown in HomeView.
//
// FLOW (maps to the GSAP timeline in steel.html):
//
//   1. IDLE → User taps "Simulate Tap" or holds phone near NFC tag
//   2. SCANNING → NFC session reads tag, extracts sharer ID
//   3. TAG_DETECTED → Backend sends SMS PIN to sharer's phone
//   4. PIN_ENTRY → User enters 4-digit PIN
//   5. VERIFYING → PIN checked with backend (scan line animation plays)
//   6. VERIFIED → PIN correct, fetching full profile
//   7. PROFILE_REVEALED → Profile card visible with all data
//
// SIMULATE MODE:
//   For development, simulateTap() auto-fills PIN digits with staggered
//   animation (0.4s per digit, matching GSAP stagger) and auto-verifies.
//   This lets you test the full visual flow without an NFC tag or SMS.

import SwiftUI
import Combine

// MARK: - VerificationViewModel
@MainActor
class VerificationViewModel: ObservableObject {

    // MARK: - Published State
    @Published var flowState: VerificationFlowState = .idle
    @Published var pinState = PINState()
    @Published var revealedProfile: SteelProfile? = nil
    @Published var isSimulating = false

    // MARK: - Services
    let nfcService = NFCService()
    private let smsService = SMSVerificationService()
    private let profileService = ProfileService()

    // Current verification session (from backend after SMS sent)
    private var currentSession: VerificationSession? = nil

    // Timer for auto-fill animation in simulate mode
    private var simulationTimers: [Task<Void, Never>] = []

    // MARK: - Computed Properties

    /// Whether we're in any verification sub-state (for HomeView state switching)
    var isInVerificationPhase: Bool {
        switch flowState {
        case .scanning, .tagDetected, .pinEntry, .verifying, .verified:
            return true
        default:
            return false
        }
    }

    // MARK: - Public Actions

    /// Simulate a full NFC tap → verify → reveal flow.
    /// Used for development and demos when no physical NFC tag is available.
    ///
    /// This replicates the GSAP timeline from steel.html:
    ///   .to('.pin-field', { backgroundColor: '#10b981', stagger: 0.4, duration: 0.4 })
    ///   .to('#scan-line', { opacity: 1, top: '0%', duration: 1.2 })
    func simulateTap() {
        isSimulating = true
        pinState.clear()

        // Cancel any existing simulation
        cancelSimulation()

        // Step 1: Transition to scanning (0.3s — quick fade)
        flowState = .scanning
        HapticsService.shared.play(.nfcDetected)

        // Step 2: After 0.8s, "detect" tag
        let step2 = Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled else { return }
            flowState = .tagDetected(sharerId: "steel_001")

            // Step 3: After 0.5s, move to PIN entry
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            flowState = .pinEntry

            // Step 4: Auto-fill PIN digits with stagger (0.4s each — matches GSAP stagger)
            // This creates the satisfying one-by-one fill animation
            for digit in [1, 2, 3, 4] {
                try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s stagger
                guard !Task.isCancelled else { return }
                withAnimation(SteelTheme.Animation.standard) {
                    pinState.appendDigit(digit)
                }
                HapticsService.shared.play(.pinDigitEntered)
            }

            // Step 5: After last digit, start verification
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            flowState = .verifying

            // Step 6: "Verify" for 1.2s (scan line animation plays during this)
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            guard !Task.isCancelled else { return }
            HapticsService.shared.play(.pinCorrect)
            flowState = .verified

            // Step 7: Fetch profile and reveal
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            revealedProfile = SteelProfile.mock
            flowState = .profileRevealed
            isSimulating = false
        }

        simulationTimers.append(step2)
    }

    /// Start a real NFC scan session.
    /// Triggers the system NFC sheet and reads a Steel tag.
    func startNFCScan() {
        flowState = .scanning
        isSimulating = false

        nfcService.beginScanning { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }

                switch result {
                case .success(let data):
                    HapticsService.shared.play(.nfcDetected)
                    self.flowState = .tagDetected(sharerId: data.sharerId)
                    await self.initiateVerification(sharerId: data.sharerId)

                case .failure:
                    self.flowState = .error(.tagReadFailed)
                }
            }
        }
    }

    /// Enter a single PIN digit (from manual keypad input).
    func enterDigit(_ digit: Int) {
        guard case .pinEntry = flowState else { return }

        withAnimation(SteelTheme.Animation.standard) {
            pinState.appendDigit(digit)
        }

        // Auto-submit when all 4 digits entered
        if pinState.isComplete {
            Task {
                await verifyPIN()
            }
        }
    }

    /// Reset back to idle state. Cancels any in-progress operations.
    func reset() {
        cancelSimulation()
        flowState = .idle
        pinState.clear()
        revealedProfile = nil
        isSimulating = false
        currentSession = nil
    }

    // MARK: - Private Flow Methods

    /// After reading an NFC tag, send SMS PIN to the sharer and wait for input.
    private func initiateVerification(sharerId: String) async {
        do {
            // Ask backend to send SMS PIN to the sharer
            let session = try await smsService.sendVerificationPIN(sharerId: sharerId)
            currentSession = session

            // Move to PIN entry state
            flowState = .pinEntry
        } catch {
            flowState = .error(.networkError)
        }
    }

    /// Verify the entered PIN with the backend.
    private func verifyPIN() async {
        guard let session = currentSession else {
            // If in simulate mode without a session, check against simulated PIN
            if pinState.pinString == "1234" {
                flowState = .verifying

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                HapticsService.shared.play(.pinCorrect)
                flowState = .verified

                try? await Task.sleep(nanoseconds: 500_000_000)
                revealedProfile = SteelProfile.mock
                flowState = .profileRevealed
            } else {
                HapticsService.shared.play(.pinIncorrect)
                flowState = .error(.pinIncorrect)
            }
            return
        }

        flowState = .verifying

        do {
            let isValid = try await smsService.verifyPIN(
                sessionId: session.sessionId,
                pin: pinState.pinString,
                simulatedPIN: session.simulatedPIN
            )

            if isValid {
                HapticsService.shared.play(.pinCorrect)
                flowState = .verified

                // Fetch full profile
                let profile = try await profileService.fetchFullProfile(
                    memberId: session.sharerId,
                    verificationSessionId: session.sessionId
                )
                revealedProfile = profile
                flowState = .profileRevealed
            } else {
                HapticsService.shared.play(.pinIncorrect)
                pinState.clear()
                flowState = .error(.pinIncorrect)
            }
        } catch {
            flowState = .error(.networkError)
        }
    }

    /// Cancel any running simulation timers.
    private func cancelSimulation() {
        simulationTimers.forEach { $0.cancel() }
        simulationTimers.removeAll()
    }
}
