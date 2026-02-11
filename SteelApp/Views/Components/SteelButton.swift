// SteelButton.swift
// Steel by Exo — Branded Button Component
//
// Standard button styles used throughout the Steel app.
// Maps to the button styles in steel.html:
//   Primary:   bg-brand-accent text-black (emerald background, dark text)
//   Secondary: bg-white/10 text-white (glass background, white text)
//
// Includes:
//   - Scale animation on press (transform: hover:scale-105 from HTML)
//   - Haptic feedback on tap
//   - Loading state with spinner
//
// Usage:
//   SteelButton("Simulate Tap", style: .primary) { doSomething() }
//   SteelButton("Join Waitlist", style: .secondary) { doSomething() }

import SwiftUI

// MARK: - Button Style
enum SteelButtonStyle {
    case primary     // Emerald bg, dark text — CTAs
    case secondary   // Glass bg, white text — secondary actions
    case ghost       // No bg, emerald text — tertiary
}

// MARK: - SteelButton
struct SteelButton: View {
    let title: String
    let style: SteelButtonStyle
    let isLoading: Bool
    let isFullWidth: Bool
    let action: () -> Void

    init(
        _ title: String,
        style: SteelButtonStyle = .primary,
        isLoading: Bool = false,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticsService.shared.play(.buttonTap)
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(textColor)
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(SteelTheme.Fonts.button)
                        .tracking(0.5)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 14)
            .padding(.horizontal, isFullWidth ? 0 : 32)
            .foregroundStyle(textColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: buttonRadius))
            .overlay(
                // Border for secondary style
                RoundedRectangle(cornerRadius: buttonRadius)
                    .stroke(borderColor, lineWidth: style == .ghost ? 1 : 0)
            )
        }
        .buttonStyle(SteelButtonPressStyle())
        .disabled(isLoading)
    }

    // MARK: - Style Properties

    private var backgroundColor: Color {
        switch style {
        case .primary:   return SteelTheme.Colors.accent
        case .secondary: return Color.white.opacity(0.10)
        case .ghost:     return Color.clear
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:   return SteelTheme.Colors.background
        case .secondary: return SteelTheme.Colors.text
        case .ghost:     return SteelTheme.Colors.accent
        }
    }

    private var borderColor: Color {
        switch style {
        case .ghost:     return SteelTheme.Colors.accent.opacity(0.3)
        default:         return Color.clear
        }
    }

    private var buttonRadius: CGFloat {
        switch style {
        case .primary:   return SteelTheme.Radius.medium
        case .secondary: return SteelTheme.Radius.medium
        case .ghost:     return SteelTheme.Radius.medium
        }
    }
}

// MARK: - Press Animation Style
// Creates the scale-down effect when the button is pressed.
// Maps to CSS: transform: hover:scale-105, active:scale-[0.98]
struct SteelButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(SteelTheme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        SteelTheme.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 16) {
            SteelButton("Simulate Tap", style: .primary) { }
            SteelButton("Join the Waitlist", style: .secondary) { }
            SteelButton("Learn More", style: .ghost) { }
            SteelButton("Loading...", style: .primary, isLoading: true) { }
        }
        .padding(32)
    }
}
