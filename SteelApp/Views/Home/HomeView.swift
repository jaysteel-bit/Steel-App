// HomeView.swift
// Steel by Exo — Main App Screen
//
// This is the primary screen after onboarding. It manages the three visual states
// from the HTML prototype's phone demo:
//
//   1. LOCKED STATE (#locked in HTML):
//      - Orb with particles pulsing
//      - "Tap to Connect" headline
//      - "Simulate Tap" button (or real NFC trigger)
//
//   2. VERIFICATION STATE (#verification in HTML):
//      - Active orb (larger, scan line)
//      - 4 PIN fields filling with emerald
//      - "Verifying secure access..." text
//
//   3. PROFILE STATE (#profile in HTML):
//      - Glass card with full profile data
//      - Photo, name (metallic text), headline
//      - Social links grid (Instagram, LinkedIn, Phone)
//      - "Add to Contacts" + "Join the Waitlist" buttons
//
// The GSAP timeline from HTML is replicated with SwiftUI state transitions:
//   tl.to('#locked', { opacity: 0 })
//     .to('#verification', { opacity: 1 })
//     .to('.pin-field', { backgroundColor: emerald, stagger: 0.4 })
//     .to('#scan-line', { opacity: 1, top: '0%' })
//     .to('#verification', { opacity: 0 })
//     .to('#profile', { opacity: 1 })

import SwiftUI

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = VerificationViewModel()

    var body: some View {
        ZStack {
            // Base background
            SteelTheme.Colors.background
                .ignoresSafeArea()

            // Ambient emerald glows
            AmbientGlowView()

            // Background particles
            ParticleEmitterView(style: .background)
                .ignoresSafeArea()
                .opacity(0.4)

            // Main content — state-driven
            VStack(spacing: 0) {
                // Top bar with Steel branding
                topBar
                    .padding(.horizontal, SteelTheme.Spacing.lg)
                    .padding(.top, SteelTheme.Spacing.sm)

                Spacer()

                // Phone demo container (maps to .phone-screen in HTML)
                phoneContainer
                    .padding(.horizontal, SteelTheme.Spacing.lg)

                Spacer()
            }
        }
    }

    // MARK: - Top Bar
    // Minimal top bar with Steel branding
    private var topBar: some View {
        HStack {
            Text("STEEL")
                .font(SteelTheme.Fonts.sans(size: 14, weight: .medium))
                .tracking(3)
                .foregroundStyle(SteelTheme.Colors.textMuted.opacity(0.6))

            Spacer()

            // Status indicator
            Circle()
                .fill(viewModel.flowState == .idle
                      ? SteelTheme.Colors.accent.opacity(0.5)
                      : SteelTheme.Colors.accent)
                .frame(width: 8, height: 8)
        }
    }

    // MARK: - Phone Container
    // The main card that holds all three states.
    // Maps to .phone-screen in HTML:
    //   bg-brand-dark, rounded-3xl, border-white/10, h-[700px]
    private var phoneContainer: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: SteelTheme.Radius.large)
                .fill(SteelTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: SteelTheme.Radius.large)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)

            // State content with transitions
            ZStack {
                // STATE 1: Locked — orb + tap button
                if viewModel.flowState == .idle {
                    NFCTapView(viewModel: viewModel)
                        .transition(.opacity)
                }

                // STATE 2: Verification — PIN entry + scan
                if viewModel.isInVerificationPhase {
                    VerificationView(viewModel: viewModel)
                        .transition(.opacity)
                }

                // STATE 3: Profile revealed — glass card
                if viewModel.flowState == .profileRevealed {
                    ProfileRevealView(
                        profile: viewModel.revealedProfile ?? .mock,
                        onReset: { viewModel.reset() }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // ERROR state
                if case .error(let error) = viewModel.flowState {
                    errorView(error: error)
                        .transition(.opacity)
                }
            }
            .padding(SteelTheme.Spacing.lg)
            .animation(SteelTheme.Animation.standard, value: viewModel.flowState)
        }
        .frame(maxHeight: 650)
    }

    // MARK: - Error View
    private func errorView(error: VerificationError) -> some View {
        VStack(spacing: SteelTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(SteelTheme.Colors.accent)

            Text(error.message)
                .font(SteelTheme.Fonts.body)
                .foregroundStyle(SteelTheme.Colors.textMuted)
                .multilineTextAlignment(.center)

            SteelButton("Try Again") {
                viewModel.reset()
            }
        }
        .padding(SteelTheme.Spacing.xl)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AppState())
}
