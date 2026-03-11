import SwiftUI

enum AppState: Equatable {
    case loading
    case unauthenticated
    case authenticated
    // case onboarding(OnboardingStep)
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

        let oldState = state
        state = newState
        logTransition(from: oldState, to: newState)
    }

    // MARK: - Validation

    private func isValidTransition(from: AppState, to: AppState) -> Bool {
        switch (from, to) {
        // From loading
        case (.loading, .unauthenticated): return true
        case (.loading, .authenticated): return true
        // case (.loading, .error): return true

        // From unauthenticated
        case (.unauthenticated, .authenticated): return true
        // case (.unauthenticated, .onboarding): return true
        // case (.unauthenticated, .error): return true

        // From authenticated
        case (.authenticated, .unauthenticated): return true  // Logout
        // case (.authenticated, .error): return true

        // From error
        // case (.error, .loading): return true  // Retry
        // case (.error, .unauthenticated): return true

        // From onboarding
        // case (.onboarding, .onboarding): return true  // Step changes
        // case (.onboarding, .authenticated): return true
        // case (.onboarding, .unauthenticated): return true  // Cancelled

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
        
        // TODO: Validate user session from Keychain/UserDefaults here
        // let isValidSession = await AuthService.validateSession()
        let isValidSession = false // Mocking false for now
        
        // Ensure minimum display time for loading screen (prevent flicker)
        let elapsed = Date().timeIntervalSince(startTime)
        let minimumDuration: TimeInterval = 0.5
        if elapsed < minimumDuration {
            try? await Task.sleep(for: .seconds(minimumDuration - elapsed))
        }
        
        if isValidSession {
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
