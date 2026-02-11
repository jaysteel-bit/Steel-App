// VerificationView.swift
// Steel by Exo — PIN Verification Screen
//
// This is the SECOND state — the verification/consent flow.
// Maps to #verification in steel.html:
//   - Active orb (w-64 h-64, larger, with scan line)
//   - 4 PIN fields that fill with emerald green one by one
//   - "Verifying secure access..." text
//
// The GSAP timeline sequence from HTML:
//   1. #locked fades out
//   2. #verification fades in
//   3. .pin-field backgrounds stagger to emerald (0.4s each)
//   4. #scan-line animates top to bottom
//   5. #verification fades out → #profile fades in
//
// In the real app:
//   1. NFC tag is read → sharer ID extracted
//   2. Backend sends SMS PIN to sharer's phone
//   3. Receiver enters PIN digits on this screen
//   4. PIN verified → transitions to ProfileRevealView
//
// In simulate mode (development):
//   PIN auto-fills with animation → auto-verifies → reveals profile

import SwiftUI

// MARK: - VerificationView
struct VerificationView: View {
    @ObservedObject var viewModel: VerificationViewModel

    // Animation states
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: SteelTheme.Spacing.xxl) {
            Spacer()

            // Active orb (larger, with scan line during scanning)
            OrbView(
                isActive: true,
                showScanLine: viewModel.flowState == .verifying
            )
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.8)

            // PIN Entry fields
            pinFieldsView
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)

            // Status text
            Text(statusText)
                .font(SteelTheme.Fonts.caption)
                .foregroundStyle(SteelTheme.Colors.textMuted)
                .opacity(isVisible ? 1 : 0)

            // Manual PIN input (for real verification, not simulation)
            if !viewModel.isSimulating {
                pinKeypad
                    .opacity(isVisible ? 1 : 0)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(SteelTheme.Animation.slow.delay(0.3)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }

    // MARK: - PIN Fields
    // The 4 PIN entry fields that fill with emerald.
    // Maps to .pin-container in HTML:
    //   <div class="pin-field w-12 h-12 bg-brand-gray rounded-lg border-2 border-white/30">
    // When filled (from GSAP): backgroundColor: '#10b981', borderColor: '#10b981'
    private var pinFieldsView: some View {
        HStack(spacing: SteelTheme.Spacing.md) {
            ForEach(0..<4, id: \.self) { index in
                PINDigitField(
                    digit: viewModel.pinState.digits[index],
                    isFilled: viewModel.pinState.digits[index] != nil,
                    isActive: index == viewModel.pinState.enteredCount
                )
            }
        }
    }

    // MARK: - Status Text
    private var statusText: String {
        switch viewModel.flowState {
        case .tagDetected:      return "Steel member detected..."
        case .pinEntry:         return "Enter the PIN shown on the sharer's phone"
        case .verifying:        return "Verifying secure access..."
        case .verified:         return "Access granted"
        default:                return "Verifying secure access..."
        }
    }

    // MARK: - PIN Keypad
    // Simple numeric keypad for manual PIN entry
    private var pinKeypad: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 16) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        keypadButton(number: number)
                    }
                }
            }
            // Bottom row: empty, 0, delete
            HStack(spacing: 16) {
                Color.clear.frame(width: 60, height: 44)
                keypadButton(number: 0)
                Button(action: {
                    viewModel.pinState.removeLastDigit()
                }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 18))
                        .foregroundStyle(SteelTheme.Colors.textMuted)
                        .frame(width: 60, height: 44)
                }
            }
        }
    }

    private func keypadButton(number: Int) -> some View {
        Button(action: {
            HapticsService.shared.play(.pinDigitEntered)
            viewModel.enterDigit(number)
        }) {
            Text("\(number)")
                .font(SteelTheme.Fonts.sans(size: 20, weight: .medium))
                .foregroundStyle(SteelTheme.Colors.text)
                .frame(width: 60, height: 44)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - PINDigitField
// Individual PIN digit field — maps to .pin-field in HTML
struct PINDigitField: View {
    let digit: Int?
    let isFilled: Bool
    let isActive: Bool

    var body: some View {
        ZStack {
            // Background — transitions from gray to emerald when filled
            RoundedRectangle(cornerRadius: SteelTheme.Radius.small)
                .fill(isFilled ? SteelTheme.Colors.accent : SteelTheme.Colors.surfaceAlt)
                .animation(SteelTheme.Animation.standard, value: isFilled)

            // Border — white/30 normally, emerald when filled
            RoundedRectangle(cornerRadius: SteelTheme.Radius.small)
                .stroke(
                    isFilled ? SteelTheme.Colors.accent
                    : isActive ? Color.white.opacity(0.5)
                    : Color.white.opacity(0.3),
                    lineWidth: 2
                )
                .animation(SteelTheme.Animation.standard, value: isFilled)

            // Digit text (shown when filled)
            if let digit = digit {
                Text("\(digit)")
                    .font(SteelTheme.Fonts.sans(size: 20, weight: .semibold))
                    .foregroundStyle(isFilled ? SteelTheme.Colors.background : SteelTheme.Colors.text)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 48, height: 48)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.surface
            .ignoresSafeArea()

        VerificationView(viewModel: {
            let vm = VerificationViewModel()
            return vm
        }())
    }
}
