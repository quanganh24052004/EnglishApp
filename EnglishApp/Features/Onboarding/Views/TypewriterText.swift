import SwiftUI

struct TypewriterText: View {
    let fullText: String
    let speed: TimeInterval
    @Binding var isFinished: Bool
    
    @State private var displayedText: String = ""
    
    init(_ text: String, speed: TimeInterval = 0.03, isFinished: Binding<Bool>) {
        self.fullText = text
        self.speed = speed
        self._isFinished = isFinished
    }
    
    var body: some View {
        Text(displayedText)
            .task(id: fullText) {
                displayedText = ""
                isFinished = false
                
                for character in fullText {
                    guard !Task.isCancelled else { return }
                    displayedText.append(character)
                    try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
                }
                
                if !Task.isCancelled {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isFinished = true
                    }
                }
            }
    }
}
