import SwiftUI
import WidgetKit

private struct DayEntry: TimelineEntry {
    let date: Date
    let title: String?
    let startDate: Date?

    var progress: AnniversaryProgress {
        AnniversaryCalculator.progress(from: startDate ?? date, to: date)
    }
}

private struct DayProvider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: .now, title: "우리의 시작",
                 startDate: Calendar.current.date(byAdding: .day, value: -120, to: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let current = currentEntry()
        let calendar = Calendar.autoupdatingCurrent
        let today = calendar.startOfDay(for: current.date)
        var entries = [current]
        // Supply future midnight entries, so a delayed refresh doesn't freeze D+.
        for day in 1...7 {
            guard let date = calendar.date(byAdding: .day, value: day, to: today) else { continue }
            entries.append(DayEntry(date: date, title: current.title, startDate: current.startDate))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func currentEntry() -> DayEntry {
        let defaults = UserDefaults(suiteName: "group.com.dotoryman.dotorycount")
        return DayEntry(date: .now, title: defaults?.string(forKey: "widget.title"),
                        startDate: defaults?.object(forKey: "widget.startDate") as? Date)
    }
}

private struct LockWidgetView: View {
    let entry: DayEntry

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 19, weight: .medium))
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title ?? "도토리 카운트")
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                Text(entry.startDate == nil ? "기념일을 설정해 주세요" : entry.progress.counterText)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .containerBackground(for: .widget) { Color.clear }
        .accessibilityElement(children: .combine)
    }
}

private struct HomeWidgetView: View {
    let entry: DayEntry

    var body: some View {
        JarWidgetContent(progress: entry.progress, isConfigured: entry.startDate != nil)
            .containerBackground(for: .widget) {
                Color(red: 0.982, green: 0.971, blue: 0.947)
            }
            .accessibilityLabel(entry.startDate == nil
                ? "도토리 카운트. 앱에서 기념일을 설정해 주세요."
                : "\(entry.title ?? "기념일"), \(entry.progress.counterText)")
    }
}

private struct DotoryCountWidget: Widget {
    let kind = "DotoryCountWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DayProvider()) { entry in
            WidgetFamilyView(entry: entry)
        }
        .configurationDisplayName("도토리 카운트")
        .description("한 병에 담긴 시간. 유리병과 함께한 날을 확인해요.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
        .contentMarginsDisabled()
    }
}

private struct WidgetFamilyView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DayEntry

    var body: some View {
        if family == .accessoryRectangular {
            LockWidgetView(entry: entry).padding(.horizontal, 4)
        } else {
            HomeWidgetView(entry: entry)
        }
    }
}

@main
struct DotoryCountWidgetBundle: WidgetBundle {
    var body: some Widget { DotoryCountWidget() }
}
