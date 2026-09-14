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
        let arguments = ProcessInfo.processInfo.arguments
        let isUITesting = arguments.contains("--ui-testing")
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isUITesting)

        do {
            modelContainer = try ModelContainer(
                for: Anniversary.self,
                configurations: configuration
            )

            if isUITesting, arguments.contains("--ui-testing-seeded-anniversary") {
                let startDate = Calendar.current.date(byAdding: .day, value: -22, to: .now) ?? .now
                modelContainer.mainContext.insert(
                    Anniversary(title: "우리의 시작", startDate: startDate)
                )
                try modelContainer.mainContext.save()
            }
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
