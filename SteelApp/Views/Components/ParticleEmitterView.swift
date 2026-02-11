// ParticleEmitterView.swift
// Steel by Exo — Particle Effect Component
//
// Wraps CAEmitterLayer to create the particle effects from steel.html.
// The HTML prototype uses particles.js for two effects:
//   1. Background particles: Subtle emerald dots floating slowly
//   2. Orb particles: Dense white particles with connecting lines (neural look)
//
// In SwiftUI, we use UIViewRepresentable to bridge CAEmitterLayer.
// CAEmitterLayer is GPU-accelerated and efficient for iOS.
//
// Usage:
//   ParticleEmitterView(style: .background)  // Ambient background
//   ParticleEmitterView(style: .orb)         // Dense neural orb

import SwiftUI
import UIKit

// MARK: - ParticleStyle
enum ParticleStyle {
    case background     // Subtle ambient particles (maps to particles-bg in HTML)
    case orb            // Dense neural/orb particles (maps to #orb in HTML)
    case celebration    // Burst effect for successful verification
}

// MARK: - ParticleEmitterView
struct ParticleEmitterView: UIViewRepresentable {
    let style: ParticleStyle

    func makeUIView(context: Context) -> ParticleHostView {
        let view = ParticleHostView()
        view.configure(style: style)
        return view
    }

    func updateUIView(_ uiView: ParticleHostView, context: Context) {
        // No dynamic updates needed — particles run continuously
    }
}

// MARK: - ParticleHostView
// UIView subclass that hosts the CAEmitterLayer.
// We use a custom UIView so we can properly size the emitter layer
// when the view's bounds change.
class ParticleHostView: UIView {
    private var emitterLayer: CAEmitterLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update emitter position and size when bounds change
        emitterLayer?.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitterLayer?.emitterSize = bounds.size
        emitterLayer?.frame = bounds
    }

    func configure(style: ParticleStyle) {
        // Remove existing emitter if reconfiguring
        emitterLayer?.removeFromSuperlayer()

        let emitter = CAEmitterLayer()
        emitter.emitterShape = style == .orb ? .circle : .rectangle
        emitter.emitterMode = .surface
        emitter.renderMode = .additive

        switch style {
        case .background:
            emitter.emitterCells = [makeBackgroundCell()]

        case .orb:
            emitter.emitterCells = [makeOrbCell(), makeOrbGlowCell()]

        case .celebration:
            emitter.emitterCells = [makeCelebrationCell()]
        }

        layer.addSublayer(emitter)
        emitterLayer = emitter
    }

    // MARK: - Cell Factories

    /// Background particles: subtle emerald dots, slow-moving, sparse.
    /// Maps to particles-bg config in HTML:
    ///   number: 30, color: #10b981, opacity: 0.3, size: 3, speed: 0.5
    private func makeBackgroundCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = makeCircleImage(diameter: 6, color: UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 1.0))
        cell.birthRate = 3                          // ~30 particles on screen at a time
        cell.lifetime = 12                          // Long-lived (slow ambient)
        cell.velocity = 8                           // Very slow movement (speed: 0.5 in HTML)
        cell.velocityRange = 5
        cell.emissionRange = .pi * 2                // Emit in all directions
        cell.alphaSpeed = -0.02                     // Fade out slowly
        cell.alphaRange = 0.3                       // Opacity variation (random: true in HTML)
        cell.scale = 0.4
        cell.scaleRange = 0.3                       // Size variation (random: true in HTML)
        return cell
    }

    /// Orb particles: dense white dots forming a neural network look.
    /// Maps to #orb config in HTML:
    ///   number: 80, color: #ffffff, opacity: 0.8, size: 2, speed: 1
    ///   line_linked: enable: true (we simulate this with glow particles)
    private func makeOrbCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = makeCircleImage(diameter: 4, color: .white)
        cell.birthRate = 15                         // Dense particle field (~80 on screen)
        cell.lifetime = 6
        cell.velocity = 15                          // Faster than background
        cell.velocityRange = 10
        cell.emissionRange = .pi * 2
        cell.alphaSpeed = -0.1
        cell.alphaRange = 0.4
        cell.scale = 0.3
        cell.scaleRange = 0.2
        return cell
    }

    /// Orb glow particles: larger, dimmer particles that create the "connected lines" feel.
    /// Since CAEmitterLayer can't draw lines between particles like particles.js,
    /// we use larger, semi-transparent particles to simulate the glow/connection effect.
    private func makeOrbGlowCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = makeCircleImage(diameter: 12, color: UIColor.white.withAlphaComponent(0.3))
        cell.birthRate = 5
        cell.lifetime = 4
        cell.velocity = 8
        cell.velocityRange = 5
        cell.emissionRange = .pi * 2
        cell.alphaSpeed = -0.15
        cell.scale = 0.5
        cell.scaleRange = 0.3
        return cell
    }

    /// Celebration particles: burst of emerald sparks when verification succeeds.
    private func makeCelebrationCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = makeCircleImage(diameter: 6, color: UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 1.0))
        cell.birthRate = 40
        cell.lifetime = 2
        cell.velocity = 80
        cell.velocityRange = 30
        cell.emissionRange = .pi * 2
        cell.alphaSpeed = -0.4
        cell.scale = 0.3
        cell.scaleRange = 0.2
        cell.yAcceleration = 50                     // Gravity-like fall
        return cell
    }

    // MARK: - Helpers

    /// Creates a simple circle image for use as particle content.
    /// CAEmitterLayer requires CGImage content.
    private func makeCircleImage(diameter: CGFloat, color: UIColor) -> CGImage? {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return image.cgImage
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 40) {
            // Background particles
            ParticleEmitterView(style: .background)
                .frame(width: 300, height: 200)
                .border(Color.white.opacity(0.1))

            // Orb particles
            ParticleEmitterView(style: .orb)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
        }
    }
}
