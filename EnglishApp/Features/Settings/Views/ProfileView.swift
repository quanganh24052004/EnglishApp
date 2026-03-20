//
//  ProfileView.swift
//  EnglishApp
//
//  Hồ Sơ - Thông tin người dùng
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppStateController.self) private var appState
    @ObservedObject private var authService = AuthService.shared

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 64, height: 64)
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        if authService.isAuthenticated {
                            Text("Người dùng")
                                .font(.headline)
                            Text("Thành viên đã đăng nhập")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Khách")
                                .font(.headline)
                            Text("Đăng nhập để lưu tiến trình")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Stats Section
            Section("Thống kê học tập") {
                HStack {
                    Label("Chuỗi ngày học", systemImage: "flame.fill")
                        .foregroundStyle(.orange)
                    Spacer()
                    Text("0 ngày")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Tổng từ đã học", systemImage: "book.fill")
                        .foregroundStyle(.blue)
                    Spacer()
                    Text("0 từ")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Khoá học hoàn thành", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Spacer()
                    Text("0")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                if authService.isAuthenticated {
                    Button(role: .destructive) {
                        authService.logout()
                        withAnimation {
                            appState.transition(to: .guest)
                        }
                    } label: {
                        Label("Đăng xuất", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } else {
                    Button {
                        withAnimation {
                            appState.transition(to: .unauthenticated)
                        }
                    } label: {
                        Label("Đăng nhập / Đăng ký", systemImage: "person.crop.circle.badge.plus")
                    }
                }
            }
        }
        .navigationTitle("Hồ Sơ")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(AppStateController())
}
