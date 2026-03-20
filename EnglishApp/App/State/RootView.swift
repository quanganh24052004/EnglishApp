import SwiftUI

struct RootView: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        Group {
            switch appState.state {
            case .loading:
                SplashScreenView()
                    .transition(.opacity)
            case .unauthenticated:
                LoginView()
                    .transition(.opacity)
            case .onboarding:
                // Survey & Onboarding App Flow
                IntroView()
                    .transition(.opacity)
            case .guest, .authenticated:
                // The Main App Flow - TabBar chính
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.state)
    }
}
