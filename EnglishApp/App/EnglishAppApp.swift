//
//  EnglishAppApp.swift
//  EnglishApp
//
//  Created by Nguyễn Quang Anh on 11/3/26.
//

import SwiftUI
import SwiftData

@main
struct EnglishAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appState = AppStateController()
    @Environment(\.scenePhase) private var scenePhase

    // Cấu hình ModelContainer với toàn bộ Schema mới
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Account.self,
            Course.self,
            Lesson.self,
            Word.self,
            Meaning.self,
            StudyRecord.self,
            LessonRecord.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }
    
    // MARK: - Scene Lifecycle
    private func handleScenePhaseChange(from: ScenePhase, to: ScenePhase) {
        switch to {
        case .active:
            // App became active — validate session
            Task {
                await appState.validateSession()
                await appState.refreshIfNeeded()
            }

        case .inactive:
            // App about to go inactive — save state
            appState.prepareForBackground()

        case .background:
            // App in background — release resources
            appState.releaseResources()

        @unknown default:
            break
        }
    }
}
