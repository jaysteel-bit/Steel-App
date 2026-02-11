// AmbientGlowView.swift
// Steel by Exo — Ambient Emerald Glow Background
//
// Ports the ambient glow divs from steel.html:
//   #ambient-glow-1: top-left, 600x600, radial-gradient emerald, blur(100px), opacity 0.15
//   #ambient-glow-2: bottom-right, same but mirrored
//
// These create the subtle emerald atmosphere that makes the app feel
// like you're in a premium, dimly-lit environment.
//
// Usage:
//   ZStack {
//       AmbientGlowView()
//       // Your content here
//   }

import SwiftUI

// MARK: - AmbientGlowView
struct AmbientGlowView: View {
    // Optional: animate the glow positions slightly for a living feel
    @State private var animateGlow = false

    var body: some View {
        ZStack {
            // Glow 1: Top-left (maps to #ambient-glow-1)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            SteelTheme.Colors.accent.opacity(0.15),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(x: -200, y: -200)
                .offset(x: animateGlow ? 20 : -20, y: animateGlow ? 15 : -15)
                .blur(radius: 60)

            // Glow 2: Bottom-right (maps to #ambient-glow-2)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            SteelTheme.Colors.accent.opacity(0.12),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(x: 200, y: 200)
                .offset(x: animateGlow ? -15 : 15, y: animateGlow ? -20 : 20)
                .blur(radius: 60)
        }
        .allowsHitTesting(false) // Pass through touches
        .onAppear {
            // Slow, subtle drift animation for organic feel
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.background
            .ignoresSafeArea()

        AmbientGlowView()

        Text("Steel by Exo")
            .font(SteelTheme.Fonts.heroTitle)
            .foregroundStyle(SteelTheme.Colors.text)
    }
}
