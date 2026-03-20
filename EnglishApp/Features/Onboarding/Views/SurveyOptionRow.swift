//
//  SurveyOptionRow.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI

struct SurveyOptionRow: View {
    let option: OnboardingOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.label)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.leading)
                    
                    if let desc = option.description {
                        Text(desc)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                if let diff = option.difficulty {
                    Text(diff)
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(diff).opacity(0.2))
                        .foregroundColor(difficultyColor(diff))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Dễ": return .green
        case "Vừa": return .orange
        case "Khó": return .red
        case "Siêu khó": return .purple
        default: return .blue
        }
    }
}
