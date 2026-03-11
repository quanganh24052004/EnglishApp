import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Ensure you add "primary01" color to your Assets!
            Color.fox.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Ensure you add "img_hi_capy" image to your Assets!
                Image("img_happy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("Capy Vocab")
                    .font(.system(size: 48, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.smooth(duration: 1.0)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
