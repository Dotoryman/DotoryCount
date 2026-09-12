import Foundation
import SwiftData

@Model
final class Anniversary: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var startDate: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.createdAt = createdAt
    }
}
