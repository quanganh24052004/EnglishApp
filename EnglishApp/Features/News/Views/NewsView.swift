//
//  NewsView.swift
//  EnglishApp
//
//  Phát triển trong tương lai
//

import SwiftUI

struct NewsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)

                Text("Bảng Tin")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Hệ thống tin tức và thông báo\nđang được phát triển.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Sắp ra mắt 🚀")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.green.opacity(0.12))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())

                Spacer()
            }
            .navigationTitle("Bảng Tin")
        }
    }
}

#Preview {
    NewsView()
}
