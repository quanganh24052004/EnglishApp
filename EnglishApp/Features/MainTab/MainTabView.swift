//
//  MainTabView.swift
//  EnglishApp
//
//  Created by Nguyễn Quang Anh on 13/3/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            // MARK: - Tab 1: Home
            HomeContentView()
                .tabItem {
                    Label("Trang Chủ", systemImage: "house.fill")
                }
                .tag(0)

            // MARK: - Tab 2: Nhiệm Vụ
            MissionsView()
                .tabItem {
                    Label("Nhiệm Vụ", systemImage: "checklist")
                }
                .tag(1)

            // MARK: - Tab 3: Giải Đấu
            TournamentsView()
                .tabItem {
                    Label("Giải Đấu", systemImage: "trophy.fill")
                }
                .tag(2)

            // MARK: - Tab 4: Bảng Tin
            NewsView()
                .tabItem {
                    Label("Bảng Tin", systemImage: "newspaper.fill")
                }
                .tag(3)

            // MARK: - Tab 5: Cài Đặt
            SettingsView()
                .tabItem {
                    Label("Cài Đặt", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppStateController())
        .modelContainer(for: Course.self, inMemory: true)
}
