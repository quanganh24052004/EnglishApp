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

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
                .task {
                    // Start app lifecycle initialization
                    await appState.initialize()
                }
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
            // App became active — validate session, refresh data
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
