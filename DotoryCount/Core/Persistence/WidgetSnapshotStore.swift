import Foundation
import WidgetKit

/// Only the small, non-sensitive summary a widget needs crosses the app boundary.
enum WidgetSnapshotStore {
    static let suiteName = "group.com.dotoryman.dotorycount"
    private static let titleKey = "widget.title"
    private static let startDateKey = "widget.startDate"

    static func publish(_ anniversary: Anniversary?) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(anniversary?.title, forKey: titleKey)
        defaults.set(anniversary?.startDate, forKey: startDateKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
