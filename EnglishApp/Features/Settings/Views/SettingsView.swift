//
//  SettingsView.swift
//  EnglishApp
//
//  Tab Cài Đặt - Hồ Sơ, Luyện Tập, Phát Âm
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Section 1: Hồ Sơ
                Section {
                    NavigationLink(destination: ProfileView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hồ Sơ")
                                    .font(.body)
                                Text("Thông tin cá nhân & thống kê")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                        }
                    }
                }

                // MARK: - Section 2: Học tập
                Section("Học tập") {
                    NavigationLink(destination: PracticeView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Luyện Tập")
                                    .font(.body)
                                Text("Ôn tập từ vựng và kiến thức")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "brain.head.profile")
                                .foregroundStyle(.green)
                                .font(.title2)
                        }
                    }

                    NavigationLink(destination: PronunciationView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("Phát Âm")
                                        .font(.body)
                                    Text("Sắp ra mắt")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.purple.opacity(0.12))
                                        .foregroundStyle(.purple)
                                        .clipShape(Capsule())
                                }
                                Text("Kiểm tra phát âm theo chuẩn IPA")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "waveform.and.mic")
                                .foregroundStyle(.purple)
                                .font(.title2)
                        }
                    }
                }

                // MARK: - Section 3: Ứng dụng
                Section("Ứng dụng") {
                    HStack {
                        Label("Phiên bản", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Cài Đặt")
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppStateController())
        .modelContainer(for: Course.self, inMemory: true)
}
