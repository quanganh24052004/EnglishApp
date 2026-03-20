//
//  PronunciationView.swift
//  EnglishApp
//
//  Phát âm - Kiểm tra phát âm IPA (Phát triển trong tương lai)
//

import SwiftUI

struct PronunciationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "waveform.and.mic")
                .font(.system(size: 64))
                .foregroundStyle(.purple)

            Text("Phát Âm IPA")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tính năng kiểm tra phát âm theo chuẩn IPA\nđang được phát triển.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("Sắp ra mắt 🚀")
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.purple.opacity(0.12))
                .foregroundStyle(.purple)
                .clipShape(Capsule())
            Spacer()
        }
        .navigationTitle("Phát Âm")
    }
}

#Preview {
    NavigationStack {
        PronunciationView()
    }
}
