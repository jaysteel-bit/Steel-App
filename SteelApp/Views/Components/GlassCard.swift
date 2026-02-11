// GlassCard.swift
// Steel by Exo — Glassmorphism Card Component
//
// Ports the `.glass` CSS class from steel.html:
//   background: rgba(255, 255, 255, 0.05);
//   border: 1px solid rgba(255, 255, 255, 0.1);
//   backdrop-filter: blur(12px);
//
// Usage:
//   GlassCard {
//       Text("Content inside glass card")
//   }
//
// This is the primary container for the profile reveal card,
// verification modals, and other elevated UI surfaces.

import SwiftUI

// MARK: - GlassCard
struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder let content: () -> Content

    init(
        cornerRadius: CGFloat = SteelTheme.Radius.medium,
        padding: CGFloat = SteelTheme.Spacing.lg,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(
                // Layered glass effect:
                // 1. Ultra-thin material blur (system-provided)
                // 2. Semi-transparent white fill
                // 3. Border stroke
                ZStack {
                    // iOS native blur material — closest to CSS backdrop-filter: blur(12px)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)

                    // Additional tint to match the rgba(255,255,255,0.05) from HTML
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(SteelTheme.Colors.glassFill)
                }
            )
            .overlay(
                // 1px border matching border: 1px solid rgba(255, 255, 255, 0.1)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(SteelTheme.Colors.glassBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Glass Modifier
// Alternative: use as a view modifier for more flexibility
// Usage: Text("Hello").glassBackground()
struct GlassBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(SteelTheme.Colors.glassFill)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(SteelTheme.Colors.glassBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = SteelTheme.Radius.medium) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.background
            .ignoresSafeArea()

        GlassCard {
            VStack(spacing: 12) {
                Text("Steel Member")
                    .font(SteelTheme.Fonts.headline)
                    .foregroundStyle(SteelTheme.Colors.text)

                Text("Glassmorphism card effect")
                    .font(SteelTheme.Fonts.captionMuted)
                    .foregroundStyle(SteelTheme.Colors.textMuted)
            }
        }
        .padding()
    }
}
