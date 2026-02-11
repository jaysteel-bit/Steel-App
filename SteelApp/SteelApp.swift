// SteelApp.swift
// Steel by Exo — App Entry Point
//
// This is the main entry point for the Steel iOS app.
// It sets up the SwiftUI app lifecycle and configures the
// initial navigation flow based on authentication state.

import SwiftUI

@main
struct SteelApp: App {
    // MARK: - Global State
    // AppState is the single source of truth for auth, onboarding, and navigation.
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                // Force dark mode globally — Steel is a dark-mode-first app.
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - RootView
// Decides which screen to show based on the user's auth/onboarding state.
// This is the single navigation root — all top-level routing happens here.
struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Base background — pure black (#050505)
            SteelTheme.Colors.background
                .ignoresSafeArea()

            switch appState.currentFlow {
            case .onboarding:
                // First-time user flow: welcome screens, invite code, profile setup
                OnboardingView()
                    .transition(.opacity)

            case .home:
                // Main app: NFC tap screen (locked state → verification → profile reveal)
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: appState.currentFlow)
    }
}
