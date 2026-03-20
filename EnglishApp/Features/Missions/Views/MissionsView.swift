//
//  MissionsView.swift
//  EnglishApp
//
//  Phát triển trong tương lai
//

import SwiftUI

struct MissionsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "checklist")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)

                Text("Nhiệm Vụ")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Hệ thống nhiệm vụ hằng ngày và\nnhiệm vụ bạn bè đang được phát triển.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Sắp ra mắt 🚀")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.blue.opacity(0.12))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())

                Spacer()
            }
            .navigationTitle("Nhiệm Vụ")
        }
    }
}

#Preview {
    MissionsView()
}
