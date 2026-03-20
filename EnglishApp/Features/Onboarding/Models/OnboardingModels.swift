import Foundation

struct OnboardingData: Codable {
    let onboardingFlow: [OnboardingStep]
}

enum StepType: String, Codable {
    case intro
    case question
    case info
    case permission
    case outro
}

struct OnboardingStep: Codable, Identifiable {
    let step: Int
    let type: StepType
    
    // Intro & Outro
    let mascotMessages: [String]?
    
    // Questions
    let questionText: String?
    let options: [OnboardingOption]?
    
    // Info
    let title: String?
    let benefits: [Benefit]?
    
    // Permissions
    let permissionType: String?
    let message: String?
    let action: String?
    
    var id: Int { step }
}

struct OnboardingOption: Codable, Identifiable {
    let id: String
    let label: String
    let mascotResponse: String?
    let difficulty: String?
    let description: String?
}

struct Benefit: Codable, Identifiable {
    let title: String
    let description: String
    
    var id: String { title }
}

// Model for exporting the final result
struct SurveySubmission: Codable {
    let question: String
    let answer: [String]
}
