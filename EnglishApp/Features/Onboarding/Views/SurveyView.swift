//
//  SurveyView.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI
import UserNotifications

struct SurveyView: View {
    @StateObject private var viewModel = SurveyViewModel()
    @Environment(AppStateController.self) private var appState
    let shape = RoundedCorner(radius: 16, corners: [.topRight, .bottomLeft, .bottomRight])

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar with Exit Button
            HStack {
                Spacer()
                Button(action: {
                    // Canceled surveying but we let them into the app as a guest
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    withAnimation {
                         appState.transition(to: .guest) 
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            if let step = viewModel.currentStep {
                ScrollView {
                    VStack(spacing: 20) {
                        switch step.type {
                        case .intro, .outro:
                            IntroOutroStepView(step: step, shape: shape, isTextAnimationFinished: $viewModel.isTextAnimationFinished)
                        case .question:
                            QuestionStepView(step: step, viewModel: viewModel, shape: shape)
                        case .info:
                            InfoStepView(step: step, isTextAnimationFinished: $viewModel.isTextAnimationFinished)
                        case .permission:
                            PermissionStepView(step: step, shape: shape, isTextAnimationFinished: $viewModel.isTextAnimationFinished)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                VStack {
                    Button(action: {
                        viewModel.nextStep {
                            // Onboarding completed! Mark status in UserDefaults and transition to App
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            withAnimation {
                                appState.transition(to: .guest) // Moving them to Main App experience as Guest
                            }
                        }
                    }) {
                        Text(viewModel.currentIndex == viewModel.steps.count - 1 ? "Hoàn thành" : "Tiếp tục")
                    }
                    .buttonStyle(PhysicalButtonStyle())
                    .disabled(!viewModel.canProceed || !viewModel.isTextAnimationFinished)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .id(viewModel.currentIndex)
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
        .background(Color("primaryBG"))
    }
}

// MARK: - Step Views

struct IntroOutroStepView: View {
    let step: OnboardingStep
    let shape: RoundedCorner
    @Binding var isTextAnimationFinished: Bool
    @State private var visibleIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let messages = step.mascotMessages {
                ForEach(Array(messages.enumerated()), id: \.offset) { index, msg in
                    if index <= visibleIndex {
                        HStack(alignment: .top, spacing: 10) {
                            Image(.imgHappy)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color("primary01"))
                            
                            TypewriterText(msg, isFinished: Binding(
                                get: { index < visibleIndex || (index == messages.count - 1 && isTextAnimationFinished) },
                                set: { finished in
                                    if finished {
                                        if index < messages.count - 1 {
                                            if visibleIndex == index {
                                                visibleIndex += 1
                                            }
                                        } else {
                                            isTextAnimationFinished = true
                                        }
                                    }
                                }
                            ))
                                .font(.system(size: 18, design: .rounded))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color("primaryBG"))
                                .clipShape(shape)
                                .overlay(shape.stroke(Color.gray.opacity(0.3), lineWidth: 2))
                        }
                        .padding(.horizontal)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    }
                }
            }
        }
        .padding(.top, 40)
    }
}

struct QuestionStepView: View {
    let step: OnboardingStep
    @ObservedObject var viewModel: SurveyViewModel
    let shape: RoundedCorner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(.imgHappy)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("primary01"))
                    .padding(.top, 20)
                
                if let questionText = step.questionText {
                    TypewriterText(questionText, isFinished: $viewModel.isTextAnimationFinished)
                        .font(.system(size: 18, design: .rounded))
                        .fontWeight(.regular)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("primaryBG"))
                        .clipShape(shape)
                        .overlay(shape.stroke(Color.gray.opacity(0.3), lineWidth: 2))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            if let options = step.options {
                if viewModel.isTextAnimationFinished {
                    VStack(spacing: 12) {
                        ForEach(options) { option in
                            SurveyOptionRow(
                                option: option,
                                isSelected: viewModel.isSelected(option, in: step)
                            ) {
                                withAnimation {
                                    viewModel.selectOption(option, in: step)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                }
                
                if let selectedOptionId = viewModel.userAnswers[step.id]?.first,
                   let selectedOption = options.first(where: { $0.id == selectedOptionId }),
                   let mascotResponse = selectedOption.mascotResponse {
                    HStack(alignment: .top, spacing: 10) {
                        Image(.imgHappy)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color("primary01"))
                            .padding(.top, 20)
                        
                        TypewriterText(mascotResponse, isFinished: .constant(false))
                            .font(.system(size: 18, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("primaryBG"))
                            .clipShape(shape)
                            .overlay(shape.stroke(Color.gray.opacity(0.3), lineWidth: 2))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .id(selectedOption.id) // Force redraw when selection changes
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                }
            }
        }
    }
}

struct InfoStepView: View {
    let step: OnboardingStep
    @Binding var isTextAnimationFinished: Bool
    @State private var visibleIndex = -1
    @State private var titleAnimationFinished = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(.imgHappy)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 40)
            
            if let title = step.title {
                TypewriterText(title, isFinished: Binding(
                    get: { titleAnimationFinished },
                    set: { finished in
                        if finished {
                            titleAnimationFinished = true
                            if visibleIndex == -1 {
                                visibleIndex = 0
                            }
                            if step.benefits == nil || step.benefits?.isEmpty == true {
                                isTextAnimationFinished = true
                            }
                        }
                    }
                ))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let benefits = step.benefits {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                        if index <= visibleIndex {
                            HStack(alignment: .top, spacing: 16) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 24))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(benefit.title)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    // Make description typewritten for pacing
                                    TypewriterText(benefit.description, isFinished: Binding(
                                        get: { index < visibleIndex || (index == benefits.count - 1 && isTextAnimationFinished) },
                                        set: { finished in
                                            if finished {
                                                if index < benefits.count - 1 {
                                                    if visibleIndex == index {
                                                        visibleIndex += 1
                                                    }
                                                } else {
                                                    isTextAnimationFinished = true
                                                }
                                            }
                                        }
                                    ))
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                            }
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                        }
                    }
                }
                .padding(20)
                .background(Color("primaryBG"))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
                .padding(.top, 20)
                .opacity(visibleIndex >= 0 ? 1 : 0) // Hide box until title is done
                .animation(.default, value: visibleIndex)
            }
        }
    }
}

struct PermissionStepView: View {
    let step: OnboardingStep
    let shape: RoundedCorner
    @Binding var isTextAnimationFinished: Bool
    @State private var requested = false
    
    var body: some View {
        VStack(spacing: 30) {
            if let message = step.message {
                HStack(alignment: .top, spacing: 10) {
                    Image(.imgHappy)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color("primary01"))
                    
                    TypewriterText(message, isFinished: $isTextAnimationFinished)
                        .font(.system(size: 18, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("primaryBG"))
                        .clipShape(shape)
                        .overlay(shape.stroke(Color.gray.opacity(0.3), lineWidth: 2))
                }
                .padding(.horizontal)
                .padding(.top, 40)
            }
            
            Image(systemName: "bell.badge.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.yellow)
            
            if let action = step.action {
                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text(requested ? "Đã yêu cầu quyền" : action)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(requested ? Color.gray.opacity(0.2) : Color.blue.opacity(0.1))
                        .foregroundColor(requested ? .gray : .blue)
                        .cornerRadius(12)
                }
                .disabled(requested)
                .padding(.horizontal)
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.requested = true
            }
            print("Quyền thông báo: \(granted)")
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
