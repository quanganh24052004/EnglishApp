//
//  IntroView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import SwiftUI

struct IntroView: View {
    @Environment(AppStateController.self) private var appState
    @State private var showSurvey = false
    
    var body: some View {
        if showSurvey {
            SurveyView()
                .transition(.opacity)
        } else {
            VStack(spacing: 16) {
                Text("Capy Vocab")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.orange)
                    .padding()
                
                Spacer()
                Image("wow") // Ensure "wow" exists in your Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 256, height: 256)
                
                Text("Memorize 500 words \n in just 1 month")
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // LUỒNG 1: Khách -> Survey
                Button(action: {
                    withAnimation {
                        showSurvey = true
                    }
                }) {
                    Text("STARTING NOW")
                }
                .buttonStyle(PhysicalButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("primaryBG").edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    IntroView()
        .environment(AppStateController())
}
