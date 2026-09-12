//
//  DotoryCountApp.swift
//  DotoryCount
//
//  Created by dotoryman on 9/12/26.
//

import SwiftUI
import SwiftData

@main
struct DotoryCountApp: App {
    private let modelContainer: ModelContainer

    init() {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isUITesting)

        do {
            modelContainer = try ModelContainer(
                for: Anniversary.self,
                configurations: configuration
            )
        } catch {
            fatalError("Unable to create local data store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
        }
        .modelContainer(modelContainer)
    }
}
