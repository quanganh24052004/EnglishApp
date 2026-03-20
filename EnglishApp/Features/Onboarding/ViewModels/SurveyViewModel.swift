//
//  SurveyViewModel.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI
import Combine

class SurveyViewModel: ObservableObject {
    @Published var steps: [OnboardingStep] = []
    @Published var currentIndex: Int = 0
    @Published var isTextAnimationFinished: Bool = false
    
    @Published var userAnswers: [Int: Set<String>] = [:]
    
    init() {
        loadSurveyData()
    }
    
    var currentStep: OnboardingStep? {
        guard currentIndex >= 0 && currentIndex < steps.count else { return nil }
        return steps[currentIndex]
    }
    
    var canProceed: Bool {
        guard let step = currentStep else { return false }
        
        switch step.type {
        case .question:
            let answers = userAnswers[step.id] ?? []
            return !answers.isEmpty
        case .intro, .info, .permission, .outro:
            return true
        }
    }
    
    func loadSurveyData() {
        // Find survey_data.json in Bundle
        guard let url = Bundle.main.url(forResource: "survey_data", withExtension: "json") else {
            print("Không tìm thấy file survey_data.json trong Bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(OnboardingData.self, from: data)
            self.steps = decodedData.onboardingFlow
        } catch {
            print("Lỗi parse JSON survey_data.json: \(error)")
        }
    }
    
    func selectOption(_ option: OnboardingOption, in step: OnboardingStep) {
        // Default to single selection for now.
        // We can check if multiple selection is needed later.
        var currentSelected = userAnswers[step.id] ?? Set<String>()
        
        if currentSelected.contains(option.id) {
            currentSelected.remove(option.id)
        } else {
            // For single selection:
            currentSelected = [option.id]
        }
        
        userAnswers[step.id] = currentSelected
    }
    
    func isSelected(_ option: OnboardingOption, in step: OnboardingStep) -> Bool {
        let currentSelected = userAnswers[step.id] ?? Set<String>()
        return currentSelected.contains(option.id)
    }
    
    func nextStep(onFinish: @escaping () -> Void) {
        if currentIndex < steps.count - 1 {
            withAnimation {
                currentIndex += 1
                isTextAnimationFinished = false
            }
        } else {
            submitData()
            onFinish()
        }
    }
    
    func submitData() {
        if let jsonResult = exportSurveyData() {
            print("----- DỮ LIỆU ĐÃ TRÍCH XUẤT (JSON) -----")
            print(jsonResult)
            
            saveToLocal(jsonString: jsonResult)
        }
    }
}

extension SurveyViewModel {
    
    func exportSurveyData() -> String? {
        
        var submissionList: [SurveySubmission] = []
        
        for step in steps where step.type == .question {
            let answerIDs = userAnswers[step.id] ?? []
            let selectedTexts = step.options?
                .filter { answerIDs.contains($0.id) }
                .map { $0.label } ?? []
            
            let submission = SurveySubmission(
                question: step.questionText ?? "",
                answer: selectedTexts
            )
            submissionList.append(submission)
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(submissionList)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Lỗi encode JSON: \(error)")
            return nil
        }
    }

    private func saveToLocal(jsonString: String) {
        UserDefaults.standard.set(jsonString, forKey: "UserSurveyResult")
        print("Đã lưu kết quả vào bộ nhớ máy!")
    }
}

