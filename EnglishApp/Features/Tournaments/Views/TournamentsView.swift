//
//  TournamentsView.swift
//  EnglishApp
//
//  Phát triển trong tương lai
//

import SwiftUI

struct TournamentsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.yellow)

                Text("Giải Đấu")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Hệ thống giải đấu giữa các người học\nđang được phát triển.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Sắp ra mắt 🚀")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.yellow.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())

                Spacer()
            }
            .navigationTitle("Giải Đấu")
        }
    }
}

#Preview {
    TournamentsView()
}
