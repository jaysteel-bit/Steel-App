// VerificationState.swift
// Steel by Exo — Verification Flow State
//
// Tracks the state of the SMS PIN verification flow.
// This maps directly to the HTML prototype's three visual states:
//   1. LOCKED:       Orb + "Tap to Connect" button
//   2. VERIFICATION: Active orb + PIN fields filling + scan line
//   3. PROFILE:      Glass card with full profile data
//
// The verification flow is what makes Steel privacy-first:
//   - Sharer gets SMS alert when someone taps their tag
//   - Sharer's phone shows PIN
//   - Receiver must enter PIN to unlock profile
//   - This ensures real-time consent for every share

import Foundation

// MARK: - VerificationFlowState
// The top-level state machine for the NFC tap → verify → reveal flow.
enum VerificationFlowState: Equatable {
    case idle                               // Waiting for NFC tap (shows locked orb)
    case scanning                           // NFC session active, reading tag
    case tagDetected(sharerId: String)      // Tag read successfully, partial profile loading
    case pinEntry                           // Waiting for user to enter PIN
    case verifying                          // PIN submitted, checking with backend
    case verified                           // PIN correct — transitioning to profile
    case profileRevealed                    // Profile card visible with full data
    case error(VerificationError)           // Something went wrong
}

// MARK: - VerificationError
// Specific errors that can occur during the verification flow.
enum VerificationError: Equatable {
    case nfcNotAvailable                    // Device doesn't support NFC
    case tagReadFailed                      // Couldn't read the NFC tag
    case invalidTag                         // Tag doesn't contain valid Steel data
    case pinIncorrect                       // Wrong PIN entered
    case pinExpired                         // PIN timed out (30-second window)
    case networkError                       // Backend unreachable
    case sharerDeclined                     // Sharer rejected the connection request

    var message: String {
        switch self {
        case .nfcNotAvailable: return "NFC is not available on this device."
        case .tagReadFailed:   return "Couldn't read the Steel tag. Try again."
        case .invalidTag:      return "This doesn't appear to be a valid Steel tag."
        case .pinIncorrect:    return "Incorrect PIN. Please check with the sharer."
        case .pinExpired:      return "Verification timed out. Tap again to retry."
        case .networkError:    return "Connection error. Please check your network."
        case .sharerDeclined:  return "The sharer has declined this connection."
        }
    }
}

// MARK: - PINState
// Tracks the 4-digit PIN entry progress.
// Each digit fills one of the four fields shown in the HTML prototype.
struct PINState: Equatable {
    var digits: [Int?] = [nil, nil, nil, nil]   // 4-digit PIN

    // How many digits have been entered so far
    var enteredCount: Int {
        digits.compactMap { $0 }.count
    }

    // Whether all 4 digits have been entered
    var isComplete: Bool {
        enteredCount == 4
    }

    // Get the full PIN as a string (e.g. "1234")
    var pinString: String {
        digits.compactMap { $0 }.map(String.init).joined()
    }

    // Add a digit to the next empty slot
    mutating func appendDigit(_ digit: Int) {
        guard let firstEmpty = digits.firstIndex(where: { $0 == nil }) else { return }
        digits[firstEmpty] = digit
    }

    // Remove the last entered digit
    mutating func removeLastDigit() {
        guard let lastFilled = digits.lastIndex(where: { $0 != nil }) else { return }
        digits[lastFilled] = nil
    }

    // Reset all digits
    mutating func clear() {
        digits = [nil, nil, nil, nil]
    }
}
