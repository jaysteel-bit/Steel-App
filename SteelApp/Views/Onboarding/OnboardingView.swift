// OnboardingView.swift
// Steel by Exo — Onboarding Flow
//
// First-time user experience. Steel is invitation-only, so onboarding is:
//   1. Welcome / Brand intro (hero text matching steel.html header)
//   2. Enter invite code
//   3. Create account (email/social — Clerk Auth)
//   4. Set up profile (name, photo, headline)
//   5. Ready to go → transition to HomeView
//
// The visual language here matches the steel.html marketing page:
//   - "Access Redefined" hero text
//   - "Steel by Exo" badge
//   - Ambient emerald glows
//   - Background particles
//
// For MVP, this is a simplified 3-page flow.
// TODO: Add invite code validation, Clerk auth integration

import SwiftUI

// MARK: - OnboardingView
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0

    // Total number of onboarding pages
    private let pageCount = 3

    var body: some View {
        ZStack {
            // Background: pure black + ambient glows + particles
            SteelTheme.Colors.background
                .ignoresSafeArea()

            AmbientGlowView()

            ParticleEmitterView(style: .background)
                .ignoresSafeArea()
                .opacity(0.6)

            // Content: paged onboarding
            VStack(spacing: 0) {
                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    // Page 1: Welcome / Brand intro
                    welcomePage
                        .tag(0)

                    // Page 2: Value proposition
                    valuePropPage
                        .tag(1)

                    // Page 3: Get started (invite code + CTA)
                    getStartedPage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(SteelTheme.Animation.standard, value: currentPage)

                Spacer()

                // Bottom: page indicator + next button
                VStack(spacing: SteelTheme.Spacing.lg) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pageCount, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage
                                      ? SteelTheme.Colors.accent
                                      : SteelTheme.Colors.textMuted.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(SteelTheme.Animation.quick, value: currentPage)
                        }
                    }

                    // Action button
                    if currentPage < pageCount - 1 {
                        SteelButton("Continue") {
                            withAnimation(SteelTheme.Animation.standard) {
                                currentPage += 1
                            }
                        }
                    } else {
                        SteelButton("Enter Steel") {
                            appState.completeOnboarding()
                        }
                    }
                }
                .padding(.horizontal, SteelTheme.Spacing.xl)
                .padding(.bottom, SteelTheme.Spacing.xxl)
            }
        }
    }

    // MARK: - Page 1: Welcome
    // Maps to the hero section of steel.html:
    //   <span>Steel by Exo</span>
    //   <h1>Access <span class="italic">Redefined.</span></h1>
    //   <p>Tap. Verify. Connect — with absolute control.</p>
    private var welcomePage: some View {
        VStack(spacing: SteelTheme.Spacing.lg) {
            // "Steel by Exo" badge
            Text("STEEL BY EXO")
                .font(SteelTheme.Fonts.badge)
                .tracking(3)
                .foregroundStyle(SteelTheme.Colors.textMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: SteelTheme.Radius.pill)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            // "Access Redefined." — hero title
            VStack(spacing: 4) {
                Text("Access")
                    .font(SteelTheme.Fonts.heroTitle)
                    .foregroundStyle(SteelTheme.Colors.text)
                Text("Redefined.")
                    .font(SteelTheme.Fonts.serifItalic(size: 48))
                    .foregroundStyle(SteelTheme.Colors.textMuted)
            }

            // Tagline
            Text("Tap. Verify. Connect —\nwith absolute control.")
                .font(SteelTheme.Fonts.bodyLight)
                .foregroundStyle(SteelTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, SteelTheme.Spacing.xl)
    }

    // MARK: - Page 2: Value Proposition
    // Maps to the benefits grid in steel.html
    private var valuePropPage: some View {
        VStack(spacing: SteelTheme.Spacing.xl) {
            Text("The Modern\nIdentity Layer")
                .font(SteelTheme.Fonts.sectionTitle)
                .foregroundStyle(SteelTheme.Colors.text)
                .multilineTextAlignment(.center)

            VStack(spacing: SteelTheme.Spacing.lg) {
                featureRow(icon: "bolt.fill", title: "SEAMLESS ACCESS",
                           description: "Tap into exclusive venues and curated experiences instantly.")
                featureRow(icon: "shield.checkered", title: "CONTROLLED CONNECTION",
                           description: "Share profiles with a tap. You decide who gets in.")
                featureRow(icon: "creditcard.fill", title: "UNIFIED IDENTITY",
                           description: "One premium platform for networking, access, and membership.")
            }
        }
        .padding(.horizontal, SteelTheme.Spacing.xl)
    }

    // MARK: - Page 3: Get Started
    private var getStartedPage: some View {
        VStack(spacing: SteelTheme.Spacing.xl) {
            // Orb visual (smaller version)
            OrbView(isActive: false)
                .scaleEffect(0.6)

            Text("Ready to Connect")
                .font(SteelTheme.Fonts.sectionTitle)
                .foregroundStyle(SteelTheme.Colors.text)

            Text("Your Steel identity awaits.\nTap a card to experience the future of sharing.")
                .font(SteelTheme.Fonts.bodyLight)
                .foregroundStyle(SteelTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, SteelTheme.Spacing.xl)
    }

    // MARK: - Feature Row Helper
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: SteelTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(SteelTheme.Colors.textMuted)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.05))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(SteelTheme.Fonts.sans(size: 12, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(SteelTheme.Colors.text)

                Text(description)
                    .font(SteelTheme.Fonts.caption)
                    .foregroundStyle(SteelTheme.Colors.textMuted)
                    .lineSpacing(2)
            }

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
