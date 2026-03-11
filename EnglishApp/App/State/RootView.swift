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
                // TODO: Replace with Login/Authentication Flow
                VStack(spacing: 20) {
                    Text("Bạn chưa đăng nhập")
                        .font(.headline)
                    Button("Đăng nhập") {
                        withAnimation {
                            appState.transition(to: .authenticated)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .transition(.opacity)
            case .authenticated:
                // The Main App Flow
                HomeContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.state)
    }
}
