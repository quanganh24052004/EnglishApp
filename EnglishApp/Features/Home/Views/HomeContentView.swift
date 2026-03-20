//
//  HomeContentView.swift
//  EnglishApp
//
//  Created by Nguyễn Quang Anh on 11/3/26.
//

import SwiftUI
import SwiftData

// ==========================================
// MARK: - 1. MÀN HÌNH CHÍNH (DANH SÁCH KHÓA HỌC)
// ==========================================
struct HomeContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppStateController.self) private var appState
    
    // Fetch toàn bộ danh sách Course từ SwiftData
    @Query private var courses: [Course]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(courses) { course in
                    NavigationLink {
                        // Chuyển hướng sang màn hình Chi tiết Khóa học
                        CourseDetailView(course: course)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.name)
                                .font(.headline)
                            Text(course.desc)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteCourses)
            }
            .navigationTitle("Khoá Học")
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                // Nút Sync Data (Tạm thời gọi hàm addSampleCourse, lát nữa có thể gọi thẳng hàm của SyncManager)
//                 ToolbarItem(placement: .navigationBarLeading) {
//                     Button(action: addSampleCourse) {
//                         Image(systemName: "arrow.triangle.2.circlepath")
//                     }
//                 }
            }
        } detail: {
            Text("Chọn một khoá học để bắt đầu")
                .foregroundColor(.gray)
        }
    }

    private func addSampleCourse() {
        // Tạm thời giữ hàm này để test UI nếu chưa gọi API
        withAnimation {
            let newCourse = Course(
                id: UUID().uuidString,
                name: "Khoá học mẫu \(Int.random(in: 1...100))",
                desc: "Mô tả mẫu..."
            )
            modelContext.insert(newCourse)
        }
    }

    private func deleteCourses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(courses[index])
            }
        }
    }
}

// ==========================================
// MARK: - 2. MÀN HÌNH BÀI HỌC (LESSON LIST)
// ==========================================
struct CourseDetailView: View {
    let course: Course
    
    var body: some View {
        List {
            // Phần Header giới thiệu khoá học
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.desc)
                        .font(.body)
                    if let sub = course.subDescription {
                        Text(sub)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Danh sách các Bài học (Lessons) bên trong Khoá học này
            Section(header: Text("Danh sách bài học (\(course.lessons.count))")) {
                // Sắp xếp bài học theo tên để UI không bị nhảy lung tung
                let sortedLessons = course.lessons.sorted { $0.name < $1.name }
                
                ForEach(sortedLessons) { lesson in
                    NavigationLink {
                        // Chuyển hướng sang màn hình Chi tiết Từ vựng
                        LessonDetailView(lesson: lesson)
                    } label: {
                        HStack {
                            Image(systemName: "book.pages")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(lesson.name).font(.headline)
                                if let subName = lesson.subName {
                                    Text(subName).font(.caption).foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Text("\(lesson.words.count) từ")
                                .font(.caption2)
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ==========================================
// MARK: - 3. MÀN HÌNH TỪ VỰNG (WORD LIST)
// ==========================================
struct LessonDetailView: View {
    let lesson: Lesson
    
    var body: some View {
        List {
            let sortedWords = lesson.words.sorted { $0.english < $1.english }
            
            ForEach(sortedWords) { word in
                NavigationLink {
                    // Chuyển hướng sang màn hình Chi tiết Nghĩa
                    WordDetailView(word: word)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(word.english)
                                .font(.title3)
                                .bold()
                            
                            HStack {
                                if let phonetic = word.phonetic {
                                    Text(phonetic)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                if let pos = word.partOfSpeech {
                                    Text("(\(pos))")
                                        .font(.caption)
                                        .italic()
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        Spacer()
                        if let cefr = word.cefr {
                            Text(cefr.uppercased())
                                .font(.caption2).bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(lesson.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ==========================================
// MARK: - 4. MÀN HÌNH CHI TIẾT NGHĨA (MEANING)
// ==========================================
struct WordDetailView: View {
    let word: Word
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header từ vựng
                VStack(spacing: 10) {
                    Text(word.english)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                    
                    if let phonetic = word.phonetic {
                        Text(phonetic)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Nút phát âm (UI mô phỏng)
                    if word.audioUrl != nil {
                        Button(action: {
                            print("Phát âm: \(word.audioUrl ?? "")")
                        }) {
                            Image(systemName: "speaker.wave.2.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.top, 30)
                
                Divider()
                
                // Danh sách các lớp nghĩa
                VStack(alignment: .leading, spacing: 20) {
                    Text("Nghĩa của từ:")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ForEach(word.meanings) { meaning in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("• \(meaning.vietnamese)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            if let exEn = meaning.exampleEn {
                                Text("Ví dụ: \(exEn)")
                                    .font(.body)
                                    .italic()
                            }
                            if let exVi = meaning.exampleVi {
                                Text("Dịch: \(exVi)")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
        }
        .navigationTitle("Chi tiết")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ==========================================
// MARK: - PREVIEW
// ==========================================
#Preview {
    HomeContentView()
        .modelContainer(for: Course.self, inMemory: true)
}
