import SwiftUI
import WidgetKit

private struct DayEntry: TimelineEntry {
    let date: Date
    let title: String?
    let startDate: Date?

    var days: Int? {
        guard let startDate else { return nil }
        return Calendar.autoupdatingCurrent.dateComponents(
            [.day],
            from: Calendar.autoupdatingCurrent.startOfDay(for: startDate),
            to: Calendar.autoupdatingCurrent.startOfDay(for: date)
        ).day
    }

    var counter: String {
        guard let days else { return "D+000" }
        return days >= 0 ? "D+\(days)" : "D\(days)"
    }

    var jarDays: Int {
        guard let startDate, let days, days >= 0 else { return 0 }
        let calendar = Calendar.autoupdatingCurrent
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: date)
        let years = max(calendar.dateComponents([.year], from: start, to: today).year ?? 0, 0)
        let jarStart = calendar.date(byAdding: .year, value: years, to: start) ?? start
        return max(calendar.dateComponents([.day], from: jarStart, to: today).day ?? 0, 0)
    }

    var capacity: Int {
        guard let startDate else { return 365 }
        let calendar = Calendar.autoupdatingCurrent
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: date)
        let years = max(calendar.dateComponents([.year], from: start, to: today).year ?? 0, 0)
        let jarStart = calendar.date(byAdding: .year, value: years, to: start) ?? start
        let next = calendar.date(byAdding: .year, value: 1, to: jarStart) ?? today
        return max(calendar.dateComponents([.day], from: jarStart, to: next).day ?? 365, 1)
    }

    var goldenDaysInJar: Set<Int> {
        guard let days, days >= 0, jarDays > 0 else { return [] }
        let jarStartElapsedDay = days - jarDays
        var result = Set<Int>()
        if days >= 100 {
            for milestone in stride(from: 100, through: days, by: 100) {
                let dayInJar = milestone - jarStartElapsedDay
                if dayInJar > 0, dayInJar <= jarDays { result.insert(dayInJar) }
            }
        }
        if jarStartElapsedDay > 0 { result.insert(1) }
        return result
    }
}

private struct DayProvider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: .now, title: "우리의 시작", startDate: Calendar.current.date(byAdding: .day, value: -120, to: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let entry = currentEntry()
        let nextDay = Calendar.autoupdatingCurrent.nextDate(
            after: entry.date,
            matching: DateComponents(hour: 0, minute: 1),
            matchingPolicy: .nextTime
        ) ?? entry.date.addingTimeInterval(86_400)
        completion(Timeline(entries: [entry], policy: .after(nextDay)))
    }

    private func currentEntry() -> DayEntry {
        let defaults = UserDefaults(suiteName: "group.com.dotoryman.dotorycount")
        return DayEntry(
            date: .now,
            title: defaults?.string(forKey: "widget.title"),
            startDate: defaults?.object(forKey: "widget.startDate") as? Date
        )
    }
}

private struct LockWidgetView: View {
    let entry: DayEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 21, weight: .medium))
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.title ?? "도토리 카운트")
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                Text(entry.startDate == nil ? "날짜를 설정해 주세요" : entry.counter)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

private struct HomeWidgetView: View {
    let entry: DayEntry

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                WidgetJarArt(days: entry.jarDays, capacity: entry.capacity,
                             goldenDays: entry.goldenDaysInJar)
                    .frame(width: min(geometry.size.width * 0.68, geometry.size.height * 0.65 * 941 / 1672),
                           height: geometry.size.height * 0.65)
                Spacer(minLength: 0)
                Text(entry.counter)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.31, green: 0.20, blue: 0.12))
                    .minimumScaleFactor(0.8)
                Text(entry.title ?? "기념일을 설정해 주세요")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .containerBackground(for: .widget) {
            Color(red: 1, green: 0.977, blue: 0.937)
        }
    }
}

private struct WidgetJarArt: View {
    let days: Int
    let capacity: Int
    let goldenDays: Set<Int>

    private var stage: Int {
        let day = min(max(days, 0), max(capacity - 1, 0))
        if day <= 8 { return day }
        return min(9 + (day - 9) * 28 / max(capacity - 9, 1), 36)
    }

    private func stage(for day: Int) -> Int {
        if day <= 8 { return max(day, 0) }
        return min(9 + (day - 9) * 28 / max(capacity - 9, 1), 36)
    }

    private var goldenIndices: Set<Int> {
        Set(goldenDays.map { stage(for: $0) - 1 })
    }

    private static let placements: [(x: CGFloat, y: CGFloat, size: CGFloat, angle: Double)] = {
        var result: [(x: CGFloat, y: CGFloat, radius: CGFloat, size: CGFloat, angle: Double)] = []
        for index in 0..<36 {
            let radius: CGFloat = 36 + CGFloat((index * 37) % 5)
            let preferredX = CGFloat(470 + ((index * 173) % 451) - 225)
            var bestX: CGFloat = 470
            var bestY: CGFloat = 0
            var bestScore = -CGFloat.infinity
            for step in 0...102 {
                let x = CGFloat(215 + step * 5)
                let dx = x - 470
                var y = 1290 - 0.00065 * dx * dx - radius
                for previous in result {
                    let separation = x - previous.x
                    let clearance = radius + previous.radius
                    if abs(separation) < clearance {
                        y = min(y, previous.y - sqrt(clearance * clearance - separation * separation))
                    }
                }
                let score = y - abs(x - preferredX) * 0.045
                if score > bestScore {
                    bestScore = score
                    bestX = x
                    bestY = y
                }
            }
            result.append((bestX, bestY, radius, index % 3 == 0 ? 190 : 148,
                           Double((index * 67) % 150 - 75)))
        }
        return result.map { ($0.x, $0.y, $0.size, $0.angle) }
    }()

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 941
            ZStack(alignment: .topLeading) {
                Image("JarEmptyBase")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height)

                ForEach(0..<stage, id: \.self) { index in
                    let placement = Self.placements[index]
                    Image(goldenIndices.contains(index) ? "GoldenAcornSprite" : (index % 3 == 0 ? "AcornSide" : "AcornSprite"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: placement.size * scale, height: placement.size * scale)
                        .rotationEffect(.degrees(placement.angle))
                        .shadow(color: .black.opacity(0.25), radius: 5 * scale, y: 5 * scale)
                        .position(x: placement.x * scale, y: placement.y * scale)
                }

                Image("JarGlassFront")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .mask {
                        Rectangle()
                            .overlay(alignment: .bottom) {
                                Ellipse().frame(width: 610 * scale, height: 170 * scale)
                                    .offset(y: -285 * scale)
                                    .blendMode(.destinationOut)
                            }
                    }
            }
        }
        .accessibilityHidden(true)
    }
}

private struct DotoryCountWidget: Widget {
    let kind = "DotoryCountWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DayProvider()) { entry in
            WidgetFamilyView(entry: entry)
        }
        .configurationDisplayName("도토리 카운트")
        .description("유리병에 쌓이는 도토리와 함께한 날을 확인해요.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

private struct WidgetFamilyView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DayEntry

    var body: some View {
        if family == .accessoryRectangular {
            LockWidgetView(entry: entry)
        } else {
            HomeWidgetView(entry: entry)
        }
    }
}

@main
struct DotoryCountWidgetBundle: WidgetBundle {
    var body: some Widget { DotoryCountWidget() }
}
