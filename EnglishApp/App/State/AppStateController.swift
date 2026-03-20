import SwiftUI

enum AppState: Equatable {
    case loading
    case unauthenticated
    case guest
    case authenticated
    case onboarding
    // case error(AppError)
}

@Observable
@MainActor
class AppStateController {
    private(set) var state: AppState = .loading

    // MARK: - State Transitions

    func transition(to newState: AppState) {
        guard isValidTransition(from: state, to: newState) else {
            assertionFailure("Invalid transition: \(state) → \(newState)")
            logInvalidTransition(from: state, to: newState)
            return
        }

        if newState == .guest || newState == .authenticated {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }

        let oldState = state
        state = newState
        logTransition(from: oldState, to: newState)
    }

    // MARK: - Validation

    private func isValidTransition(from: AppState, to: AppState) -> Bool {
        switch (from, to) {
        // From loading
        case (.loading, .unauthenticated): return true
        case (.loading, .guest): return true
        case (.loading, .authenticated): return true
        case (.loading, .onboarding): return true

        // From unauthenticated
        case (.unauthenticated, .authenticated): return true
        case (.unauthenticated, .guest): return true
        case (.unauthenticated, .onboarding): return true

        // From guest
        case (.guest, .unauthenticated): return true
        case (.guest, .authenticated): return true

        // From authenticated
        case (.authenticated, .unauthenticated): return true  // Logout
        case (.authenticated, .guest): return true // Logout to guest mode

        // From onboarding
        case (.onboarding, .unauthenticated): return true
        case (.onboarding, .guest): return true
        case (.onboarding, .authenticated): return true

        default: return false
        }
    }

    // MARK: - Logging

    private func logTransition(from: AppState, to: AppState) {
        #if DEBUG
        print("AppState: \(from) → \(to)")
        #endif
    }

    private func logInvalidTransition(from: AppState, to: AppState) {
        #if DEBUG
        print("Invalid AppState Transition: \(from) → \(to)")
        #endif
        // Log to analytics for debugging in production
    }
}

// MARK: - Lifecycle & Initialization
extension AppStateController {
    
    func initialize() async {
        let startTime = Date()
        
        // Validate user session from Keychain
        let isAuthenticated = KeychainHelper.shared.readToken() != nil
        
        // Ensure minimum display time for loading screen (prevent flicker)
        let elapsed = Date().timeIntervalSince(startTime)
        let minimumDuration: TimeInterval = 0.5
        if elapsed < minimumDuration {
            try? await Task.sleep(for: .seconds(minimumDuration - elapsed))
        }
        
        // 1. Check Onboarding Status
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if !hasCompletedOnboarding {
            transition(to: .onboarding)
        } else if isAuthenticated {
            transition(to: .authenticated)
        } else {
            transition(to: .unauthenticated)
        }
    }
    
    // Called when the App enters Foreground
    func validateSession() async {
        guard state == .authenticated else { return }
        
        // TODO: Validate current user token silently in background
    }
    
    func refreshIfNeeded() async {
        // Refresh feed, profile, etc.
    }

    // Called when the App is going to Background (Inactive)
    func prepareForBackground() {
        // Save any pending data
        // Cancel non-essential network requests
        // Prepare for potential termination
        #if DEBUG
        print("App entering background - saving data")
        #endif
    }

    // Called when the App is Backgrounded
    func releaseResources() {
        // Release cached images
        // Stop location updates if not essential
        // Reduce memory footprint
    }
}
