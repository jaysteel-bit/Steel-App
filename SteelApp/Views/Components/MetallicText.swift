// MetallicText.swift
// Steel by Exo — Metallic Shimmer Text Effect
//
// Ports the `.metallic-text` CSS class from steel.html:
//   background: linear-gradient(to right, #ffffff 20%, #a0a0a0 50%, #ffffff 80%);
//   -webkit-background-clip: text;
//   background-size: 200% auto;
//   animation: shine 5s linear infinite;
//
// This creates a premium metallic shine that sweeps across the text infinitely.
// Used for profile names, headlines, and any text that needs the luxury treatment.
//
// Usage:
//   MetallicText("Alex Rivera", font: SteelTheme.Fonts.cardName)

import SwiftUI

// MARK: - MetallicText
struct MetallicText: View {
    let text: String
    let font: Font

    // Animation state: drives the gradient position
    @State private var shimmerOffset: CGFloat = -1.0

    init(_ text: String, font: Font = SteelTheme.Fonts.cardName) {
        self.text = text
        self.font = font
    }

    var body: some View {
        Text(text)
            .font(font)
            .overlay(
                // Animated gradient overlay clipped to text shape
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white.opacity(0.8), location: 0.0),
                        .init(color: Color(hex: 0xA0A0A0), location: 0.3),
                        .init(color: .white, location: 0.5),
                        .init(color: Color(hex: 0xA0A0A0), location: 0.7),
                        .init(color: .white.opacity(0.8), location: 1.0),
                    ]),
                    startPoint: UnitPoint(x: shimmerOffset, y: 0.5),
                    endPoint: UnitPoint(x: shimmerOffset + 1.0, y: 0.5)
                )
                // Clip the gradient to the text shape
                .mask(
                    Text(text)
                        .font(font)
                )
            )
            .onAppear {
                // Start the infinite shimmer animation
                // Maps to CSS: animation: shine 5s linear infinite
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                    shimmerOffset = 2.0
                }
            }
    }
}

// MARK: - Metallic Text Modifier
// Alternative: use as a modifier on any Text view
// Usage: Text("Hello").metallicShimmer()
struct MetallicShimmerModifier: ViewModifier {
    @State private var shimmerOffset: CGFloat = -1.0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white.opacity(0.8), location: 0.0),
                        .init(color: Color(hex: 0xA0A0A0), location: 0.3),
                        .init(color: .white, location: 0.5),
                        .init(color: Color(hex: 0xA0A0A0), location: 0.7),
                        .init(color: .white.opacity(0.8), location: 1.0),
                    ]),
                    startPoint: UnitPoint(x: shimmerOffset, y: 0.5),
                    endPoint: UnitPoint(x: shimmerOffset + 1.0, y: 0.5)
                )
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                    shimmerOffset = 2.0
                }
            }
    }
}

extension View {
    func metallicShimmer() -> some View {
        modifier(MetallicShimmerModifier())
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 24) {
            MetallicText("Alex Rivera")

            MetallicText("Steel by Exo", font: SteelTheme.Fonts.headline)
        }
    }
}
