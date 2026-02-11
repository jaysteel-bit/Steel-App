// AppState.swift
// Steel by Exo — Global Application State
//
// Single source of truth for the app's navigation and auth state.
// Published properties drive the UI reactively via SwiftUI's observation system.
// This keeps all top-level state in one place so we can swap auth providers
// (Clerk, Firebase, custom) later without touching views.

import SwiftUI

// MARK: - Navigation Flow
// Represents which major flow the user is currently in.
// We'll expand this as we add more flows (settings, connections, etc.)
enum AppFlow: Equatable {
    case onboarding   // User hasn't completed initial setup
    case home         // Main app experience (NFC tap, profile, etc.)
}

// MARK: - AppState
@MainActor
class AppState: ObservableObject {

    // Which flow is active — drives RootView's navigation
    @Published var currentFlow: AppFlow = .onboarding

    // Whether the user has a valid auth session
    // TODO: Replace with real Clerk/auth check on launch
    @Published var isAuthenticated: Bool = false

    // The currently logged-in user's profile (nil if not logged in)
    @Published var currentUserProfile: SteelProfile? = nil

    // Whether onboarding has been completed (persisted to UserDefaults)
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "steel_onboarding_completed")
        }
    }

    init() {
        // Restore persisted onboarding state
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "steel_onboarding_completed")

        // If user already completed onboarding, go straight to home
        if hasCompletedOnboarding {
            currentFlow = .home
        }
    }

    // MARK: - Actions

    /// Call when user finishes onboarding (after invite code + profile setup)
    func completeOnboarding() {
        hasCompletedOnboarding = true
        currentFlow = .home
    }

    /// Call when user logs in successfully
    func signIn(profile: SteelProfile) {
        isAuthenticated = true
        currentUserProfile = profile
        currentFlow = .home
    }

    /// Call when user logs out or session expires
    func signOut() {
        isAuthenticated = false
        currentUserProfile = nil
        // Don't reset onboarding — they already completed it
        currentFlow = .onboarding
    }
}
