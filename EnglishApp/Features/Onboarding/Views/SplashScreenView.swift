import SwiftUI
import SwiftData

struct SplashScreenView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var isAnimating = false
    @State private var dotCount = 0
    @State private var statusText = "Đang tải..."
    
    private let minimumDisplayTime: TimeInterval = 2.5
    
    var body: some View {
        ZStack {
            Color.fox.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("img_happy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("Capy Vocab")
                    .font(.system(size: 48, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Trạng thái sync
                HStack(spacing: 4) {
                    Text(statusText)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    Text(String(repeating: ".", count: dotCount))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .animation(.easeInOut(duration: 0.4), value: dotCount)
                }
                .padding(.top, 16)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.smooth(duration: 0.8)) {
                isAnimating = true
            }
            startDotAnimation()
            Task { await runStartupSequence() }
        }
    }
    
    // MARK: - Startup Logic
    
    /// Chạy SONG SONG: min 2.5s hiển thị + sync dữ liệu từ server.
    /// Khi cả 2 xong, chuyển sang màn hình tiếp theo.
    private func runStartupSequence() async {
        await withTaskGroup(of: Void.self) { group in
            // Tác vụ 1: Thời gian tối thiểu hiển thị Splash
            group.addTask {
                try? await Task.sleep(for: .seconds(minimumDisplayTime))
            }
            
            // Tác vụ 2: Đồng bộ dữ liệu từ server
            group.addTask { @MainActor in
                do {
                    await MainActor.run { statusText = "Đang đồng bộ dữ liệu" }
                    try await SyncManager.shared.pullStaticCourses(context: modelContext)
                    await MainActor.run { statusText = "Hoàn tất" }
                } catch SyncError.unauthenticated {
                    // Guest mode: server trả về không cần Token, bỏ qua lỗi này
                    await MainActor.run { statusText = "Hoàn tất" }
                } catch {
                    // Lỗi mạng hoặc server - không block user
                    await MainActor.run { statusText = "Tiếp tục offline" }
                    print("Sync lỗi (sẽ thử lại sau): \(error.localizedDescription)")
                }
            }
        }
        // Cả 2 tác vụ đã xong → Chuyển trạng thái App
        await appState.initialize()
    }
    
    // MARK: - Dot Animation
    
    private func startDotAnimation() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            MainActor.assumeIsolated {
                if appState.state != .loading {
                    timer.invalidate()
                    return
                }
                dotCount = (dotCount + 1) % 4
            }
        }
        RunLoop.main.add(timer, forMode: .common)
    }
}

#Preview {
    SplashScreenView()
        .environment(AppStateController())
}
