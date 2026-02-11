// ProfileRevealView.swift
// Steel by Exo — Profile Card (Unlocked State)
//
// This is the THIRD and final state — the profile reveal.
// Maps directly to #profile in steel.html:
//
//   <div class="glass rounded-2xl p-8 w-full text-center space-y-6">
//     <img src="..." class="w-32 h-32 rounded-full border-4 border-brand-accent/50">
//     <h1 class="font-serif text-4xl italic metallic-text">Alex Rivera</h1>
//     <p class="text-sm text-brand-muted">Creative Director | NYC</p>
//     <span class="bg-brand-accent/10 text-brand-accent">Steel Member</span>
//     <div class="grid grid-cols-3 gap-6">
//       [Instagram] [LinkedIn] [Phone]
//     </div>
//     <button>Add to Contacts</button>
//     <button>Join the Waitlist</button>
//   </div>
//
// GSAP animation on reveal:
//   gsap.from('#profile > .glass > *', { y: 20, opacity: 0, stagger: 0.1, duration: 0.8 })
//
// This view is the payoff — the moment the receiver sees the sharer's profile
// after successful PIN verification. It should feel like unwrapping a gift.

import SwiftUI

// MARK: - ProfileRevealView
struct ProfileRevealView: View {
    let profile: SteelProfile
    let onReset: () -> Void

    // Staggered entrance animation states
    @State private var showAvatar = false
    @State private var showName = false
    @State private var showHeadline = false
    @State private var showBadge = false
    @State private var showSocials = false
    @State private var showActions = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            // Glass card container (maps to .glass in HTML)
            GlassCard(cornerRadius: SteelTheme.Radius.large) {
                VStack(spacing: SteelTheme.Spacing.lg) {

                    // MARK: - Avatar
                    // Maps to: <img ... class="w-32 h-32 rounded-full border-4 border-brand-accent/50">
                    avatarView
                        .opacity(showAvatar ? 1 : 0)
                        .offset(y: showAvatar ? 0 : 20)

                    // MARK: - Name (Metallic Text)
                    // Maps to: <h1 class="font-serif text-4xl italic metallic-text">Alex Rivera</h1>
                    MetallicText(profile.displayName, font: SteelTheme.Fonts.cardName)
                        .opacity(showName ? 1 : 0)
                        .offset(y: showName ? 0 : 20)

                    // MARK: - Headline
                    // Maps to: <p class="text-sm text-brand-muted">Creative Director | NYC</p>
                    Text(profile.headline)
                        .font(SteelTheme.Fonts.caption)
                        .foregroundStyle(SteelTheme.Colors.textMuted)
                        .opacity(showHeadline ? 1 : 0)
                        .offset(y: showHeadline ? 0 : 20)

                    // MARK: - Membership Badge
                    // Maps to: <span class="bg-brand-accent/10 text-brand-accent text-xs">Steel Member</span>
                    Text(profile.membershipTier.displayName.uppercased())
                        .font(SteelTheme.Fonts.badge)
                        .tracking(1.5)
                        .foregroundStyle(SteelTheme.Colors.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(SteelTheme.Colors.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: SteelTheme.Radius.pill))
                        .opacity(showBadge ? 1 : 0)
                        .offset(y: showBadge ? 0 : 20)

                    // MARK: - Social Links Grid
                    // Maps to: <div class="grid grid-cols-3 gap-6 mt-8">
                    socialLinksGrid
                        .opacity(showSocials ? 1 : 0)
                        .offset(y: showSocials ? 0 : 20)
                        .padding(.top, SteelTheme.Spacing.md)

                    // MARK: - Action Buttons
                    // Maps to the two buttons at bottom of profile card
                    actionButtons
                        .opacity(showActions ? 1 : 0)
                        .offset(y: showActions ? 0 : 20)
                        .padding(.top, SteelTheme.Spacing.md)
                }
            }
        }
        .onAppear {
            // Staggered entrance — mimics the GSAP stagger animation:
            //   gsap.from('#profile > .glass > *', { y: 20, opacity: 0, stagger: 0.1, duration: 0.8 })
            HapticsService.shared.play(.profileRevealed)

            let baseDelay: Double = 0.1
            let stagger: Double = 0.1

            withAnimation(SteelTheme.Animation.slow.delay(baseDelay)) { showAvatar = true }
            withAnimation(SteelTheme.Animation.slow.delay(baseDelay + stagger)) { showName = true }
            withAnimation(SteelTheme.Animation.slow.delay(baseDelay + stagger * 2)) { showHeadline = true }
            withAnimation(SteelTheme.Animation.slow.delay(baseDelay + stagger * 3)) { showBadge = true }
            withAnimation(SteelTheme.Animation.slow.delay(baseDelay + stagger * 4)) { showSocials = true }
            withAnimation(SteelTheme.Animation.slow.delay(baseDelay + stagger * 5)) { showActions = true }
        }
    }

    // MARK: - Avatar View
    private var avatarView: some View {
        // In production, use AsyncImage with the profile.avatarURL
        // For now, use a placeholder that matches the HTML prototype
        ZStack {
            Circle()
                .fill(SteelTheme.Colors.surfaceAlt)
                .frame(width: 128, height: 128)

            // AsyncImage for loading remote avatar
            if let avatarURL = profile.avatarURL, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .clipShape(Circle())
                    case .failure:
                        initialsView
                    case .empty:
                        ProgressView()
                            .tint(SteelTheme.Colors.accent)
                            .frame(width: 128, height: 128)
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        // Border: border-4 border-brand-accent/50
        .overlay(
            Circle()
                .stroke(SteelTheme.Colors.accent.opacity(0.5), lineWidth: 4)
        )
        // Shadow for depth
        .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
    }

    // Fallback initials avatar
    private var initialsView: some View {
        Text("\(profile.firstName.prefix(1))\(profile.lastName.prefix(1))")
            .font(SteelTheme.Fonts.serif(size: 40, weight: .medium))
            .foregroundStyle(SteelTheme.Colors.text)
            .frame(width: 128, height: 128)
            .background(SteelTheme.Colors.surfaceAlt)
            .clipShape(Circle())
    }

    // MARK: - Social Links Grid
    // Maps to the 3-column grid in HTML: Instagram, LinkedIn, Phone
    private var socialLinksGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: SteelTheme.Spacing.lg) {
            ForEach(profile.publicSocials) { social in
                socialLinkItem(social: social)
            }
        }
    }

    // Individual social link — maps to the anchor tags in HTML grid
    private func socialLinkItem(social: SocialLink) -> some View {
        Button(action: {
            HapticsService.shared.play(.buttonTap)
            // TODO: Open social link or contact action
        }) {
            VStack(spacing: SteelTheme.Spacing.sm) {
                Image(systemName: social.platform.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(SteelTheme.Colors.text)

                Text(social.handle)
                    .font(SteelTheme.Fonts.captionMuted)
                    .foregroundStyle(SteelTheme.Colors.textMuted)
                    .lineLimit(1)
            }
        }
        .buttonStyle(SteelButtonPressStyle())
    }

    // MARK: - Action Buttons
    // Maps to the two buttons at bottom of HTML profile card:
    //   "Add to Contacts" (primary emerald)
    //   "Join the Waitlist" (secondary glass)
    private var actionButtons: some View {
        VStack(spacing: SteelTheme.Spacing.md) {
            SteelButton("Add to Contacts") {
                HapticsService.shared.play(.connectionSaved)
                // TODO: Save to native Contacts
            }

            SteelButton("Connect", style: .secondary) {
                // TODO: Send connection request
            }

            // Reset button (for demo purposes)
            Button(action: onReset) {
                Text("Tap Another Card")
                    .font(SteelTheme.Fonts.captionMuted)
                    .foregroundStyle(SteelTheme.Colors.textMuted.opacity(0.6))
            }
            .padding(.top, SteelTheme.Spacing.sm)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.background
            .ignoresSafeArea()

        ProfileRevealView(
            profile: .mock,
            onReset: { }
        )
        .padding()
    }
}
