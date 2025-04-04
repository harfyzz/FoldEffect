//
//  FoldEffectApp.swift
//  FoldEffect
//
//  Created by Afeez Yunus on 02/04/2025.
//

import SwiftUI
import SwiftData

@main
struct FoldEffectApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FoldImage.self
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
            UploadView()
        }.modelContainer(sharedModelContainer)
    }
}
