import Foundation
import SwiftData

@MainActor
enum PreviewContainer {
    static var empty: ModelContainer {
        makeContainer()
    }

    static var withSample: ModelContainer {
        let container = makeContainer()
        let startDate = Calendar.current.date(byAdding: .day, value: -381, to: .now) ?? .now
        container.mainContext.insert(
            Anniversary(title: "우리의 시작", startDate: startDate)
        )
        return container
    }

    private static func makeContainer() -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: Anniversary.self, configurations: configuration)
        } catch {
            fatalError("Unable to create preview data store: \(error)")
        }
    }
}
