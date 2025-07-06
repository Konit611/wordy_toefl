//
//  wordy_toeflApp.swift
//  wordy_toefl
//
//  Created by GEUNIL on 2025/07/06.
//

import SwiftUI
import SwiftData

@main
struct wordy_toeflApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Word.self,
            DailyWord.self,
            Setting.self
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
            HomeView()
                .onAppear {
                    // 앱 시작 시 백그라운드에서 데이터 초기화
                    initializeDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - 데이터 초기화 함수 (백그라운드에서 실행)
    private func initializeDataIfNeeded() {
        Task {
            await performDataInitialization()
        }
    }
    
    @MainActor
    private func performDataInitialization() async {
        await Task.detached {
            let context = ModelContext(sharedModelContainer)
            
            // DataInitializer를 사용하여 데이터 초기화
            DataInitializer.shared.initializeDataIfNeeded(context: context)
        }.value
    }
}
