// NFCTapView.swift
// Steel by Exo — Locked / NFC Tap Screen
//
// This is the FIRST state in the phone demo — the "locked" screen.
// Maps directly to #locked in steel.html:
//   - Orb with particles (w-48 h-48)
//   - "Tap to Connect" headline (font-serif italic, text-3xl)
//   - "Simulate NFC tap-to-share" subtitle
//   - "Simulate Tap" button (bg-brand-accent, rounded-full)
//
// In the real app, this screen also listens for actual NFC taps.
// The "Simulate Tap" button is for development/demo purposes
// and for when the user doesn't have a physical NFC tag.

import SwiftUI

// MARK: - NFCTapView
struct NFCTapView: View {
    @ObservedObject var viewModel: VerificationViewModel

    // Entrance animation
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: SteelTheme.Spacing.xl) {
            Spacer()

            // The orb — centerpiece of the locked state
            OrbView(isActive: false)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)

            // Text content
            VStack(spacing: SteelTheme.Spacing.md) {
                // "Tap to Connect" — maps to <h2 class="text-3xl font-serif italic">
                Text("Tap to Connect")
                    .font(SteelTheme.Fonts.serif(size: 30, weight: .regular))
                    .italic()
                    .foregroundStyle(SteelTheme.Colors.text)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)

                // Subtitle — maps to <p class="text-sm text-brand-muted">
                Text("Simulate NFC tap-to-share")
                    .font(SteelTheme.Fonts.caption)
                    .foregroundStyle(SteelTheme.Colors.textMuted)
                    .opacity(isVisible ? 1 : 0)
            }

            // "Simulate Tap" button — maps to #simulate-tap in HTML
            // In production, this also triggers a real NFC scan session
            SteelButton("Simulate Tap", isFullWidth: false) {
                viewModel.simulateTap()
            }
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)

            // Real NFC scan button (smaller, below simulate)
            if viewModel.nfcService.isNFCAvailable {
                Button(action: {
                    viewModel.startNFCScan()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 12))
                        Text("Scan Real Tag")
                            .font(SteelTheme.Fonts.captionMuted)
                    }
                    .foregroundStyle(SteelTheme.Colors.textMuted)
                }
                .opacity(isVisible ? 0.6 : 0)
            }

            Spacer()
        }
        .onAppear {
            // Staggered entrance animation
            withAnimation(SteelTheme.Animation.slow.delay(0.2)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.surface
            .ignoresSafeArea()

        NFCTapView(viewModel: VerificationViewModel())
    }
}
