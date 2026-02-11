// OrbView.swift
// Steel by Exo — Animated Orb Component
//
// The orb is the centerpiece of the "locked" state in the HTML prototype.
// It's a circular region filled with dense, neural-looking particles
// that pulses and glows to invite the user to tap.
//
// In the HTML, this is the #orb div with particles.js inside a 48x48 circle,
// and #orb-active (64x64) during verification with a scan line.
//
// Structure:
//   1. Particle emitter (fills the circle with white dots)
//   2. Radial gradient background (emerald glow)
//   3. Pulsing animation (scale oscillation)
//   4. Optional scan line (during verification)

import SwiftUI

// MARK: - OrbView
struct OrbView: View {
    // Whether the orb is in "active" mode (larger, during verification)
    let isActive: Bool
    // Whether to show the scanning line animation
    let showScanLine: Bool

    init(isActive: Bool = false, showScanLine: Bool = false) {
        self.isActive = isActive
        self.showScanLine = showScanLine
    }

    // Pulsing animation state
    @State private var isPulsing = false
    // Scan line position (0 = top, 1 = bottom)
    @State private var scanLinePosition: CGFloat = 0

    // Orb sizes matching HTML:
    //   #orb:        w-48 h-48 = 192x192 points
    //   #orb-active: w-64 h-64 = 256x256 points
    private var orbSize: CGFloat {
        isActive ? 256 : 192
    }

    var body: some View {
        ZStack {
            // Layer 1: Radial gradient background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            SteelTheme.Colors.accent.opacity(0.3),
                            SteelTheme.Colors.accent.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: orbSize / 2
                    )
                )

            // Layer 2: Particle emitter (neural network look)
            ParticleEmitterView(style: .orb)
                .clipShape(Circle())

            // Layer 3: Inner glow ring
            Circle()
                .stroke(
                    SteelTheme.Colors.accent.opacity(0.2),
                    lineWidth: 1
                )
                .padding(4)

            // Layer 4: Scan line (only during verification)
            if showScanLine {
                ScanLineView(position: $scanLinePosition)
                    .clipShape(Circle())
            }
        }
        .frame(width: orbSize, height: orbSize)
        // Pulsing scale animation
        .scaleEffect(isPulsing ? 1.05 : 0.95)
        .animation(
            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
            value: isPulsing
        )
        .onAppear {
            isPulsing = true
            if showScanLine {
                startScanLineAnimation()
            }
        }
    }

    // Animate the scan line from top to bottom and repeat
    private func startScanLineAnimation() {
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
            scanLinePosition = 1.0
        }
    }
}

// MARK: - ScanLineView
// The emerald scan line that sweeps across the orb during verification.
// Maps to the .scan-line CSS class in steel.html:
//   height: 2px, background: #10b981, box-shadow: 0 0 20px #10b981
struct ScanLineView: View {
    @Binding var position: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(SteelTheme.Colors.accent)
                .frame(height: 2)
                .shadow(color: SteelTheme.Colors.accent, radius: 10, x: 0, y: 0)
                .offset(y: position * geometry.size.height)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 40) {
            // Idle orb (locked state)
            OrbView(isActive: false)

            // Active orb with scan line (verification state)
            OrbView(isActive: true, showScanLine: true)
        }
    }
}
