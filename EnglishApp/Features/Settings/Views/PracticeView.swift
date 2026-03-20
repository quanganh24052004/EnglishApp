//
//  PracticeView.swift
//  EnglishApp
//
//  Luyện tập - Tính năng ôn tập từ vựng
//

import SwiftUI
import SwiftData

struct PracticeView: View {
    @Query private var courses: [Course]

    var body: some View {
        List {
            if courses.isEmpty {
                ContentUnavailableView(
                    "Chưa có nội dung",
                    systemImage: "books.vertical",
                    description: Text("Đồng bộ dữ liệu khoá học để bắt đầu ôn tập.")
                )
            } else {
                Section("Chọn khoá học để ôn tập") {
                    ForEach(courses) { course in
                        NavigationLink {
                            PracticeSessionView(course: course)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(course.name)
                                        .font(.headline)
                                    Text(course.desc)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("Luyện Tập")
    }
}

// MARK: - Practice Session Placeholder
struct PracticeSessionView: View {
    let course: Course

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text("Ôn tập: \(course.name)")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Tính năng ôn tập flashcard và kiểm tra\nđang được phát triển.")
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
        .navigationTitle("Ôn Tập")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PracticeView()
    }
    .modelContainer(for: Course.self, inMemory: true)
}
