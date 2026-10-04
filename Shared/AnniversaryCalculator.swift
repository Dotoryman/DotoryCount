import Foundation

struct AnniversaryMilestone: Identifiable, Equatable, Hashable {
    enum Kind: Equatable, Hashable {
        case hundredDay(Int)
        case anniversary(Int)

        var title: String {
            switch self {
            case .hundredDay(let day):
                return "\(day)일"
            case .anniversary(let year):
                return "\(year)주년"
            }
        }
    }

    let elapsedDay: Int
    let date: Date
    let kinds: [Kind]

    var id: Int { elapsedDay }

    var title: String {
        kinds.map(\.title).joined(separator: " · ")
    }

    var detail: String {
        kinds.count > 1
            ? "두 개의 소중한 기록이 같은 날에 만났어요."
            : "함께한 시간을 황금도토리로 간직했어요."
    }
}

struct JarMilestone: Identifiable, Equatable {
    let dayInJar: Int
    let milestone: AnniversaryMilestone

    var id: Int { milestone.id }
}

struct AnniversaryProgress: Equatable {
    struct Milestone: Equatable {
        let title: String
        let date: Date
        let daysRemaining: Int
    }

    let elapsedDays: Int
    let completedJars: Int
    let acornsInCurrentJar: Int
    let currentJarCapacity: Int
    let nextMilestone: Milestone
    let jarMilestones: [JarMilestone]
    let todayMilestone: AnniversaryMilestone?

    var counterText: String {
        elapsedDays >= 0 ? "D+\(elapsedDays)" : "D\(elapsedDays)"
    }

    var isWaitingToStart: Bool {
        elapsedDays < 0
    }
}

enum AnniversaryCalculator {
    static func progress(
        from startDate: Date,
        to currentDate: Date = .now,
        calendar inputCalendar: Calendar = .autoupdatingCurrent
    ) -> AnniversaryProgress {
        let calendar = inputCalendar
        let start = calendar.startOfDay(for: startDate)
        let current = calendar.startOfDay(for: currentDate)
        let elapsedDays = calendar.dateComponents([.day], from: start, to: current).day ?? 0

        guard elapsedDays >= 0 else {
            return AnniversaryProgress(
                elapsedDays: elapsedDays,
                completedJars: 0,
                acornsInCurrentJar: 0,
                currentJarCapacity: daysInAnniversaryYear(from: start, calendar: calendar),
                nextMilestone: .init(
                    title: "시작일",
                    date: start,
                    daysRemaining: abs(elapsedDays)
                ),
                jarMilestones: [],
                todayMilestone: nil
            )
        }

        var completedYears = max(
            calendar.dateComponents([.year], from: start, to: current).year ?? 0,
            0
        )
        var currentJarStart = calendar.date(byAdding: .year, value: completedYears, to: start) ?? start

        if currentJarStart > current, completedYears > 0 {
            completedYears -= 1
            currentJarStart = calendar.date(byAdding: .year, value: completedYears, to: start) ?? start
        }

        let nextAnniversary = calendar.date(byAdding: .year, value: 1, to: currentJarStart) ?? currentJarStart
        let acorns = calendar.dateComponents([.day], from: currentJarStart, to: current).day ?? 0
        let capacity = calendar.dateComponents([.day], from: currentJarStart, to: nextAnniversary).day ?? 365
        let currentJarStartDay = calendar.dateComponents([.day], from: start, to: currentJarStart).day ?? 0
        let milestones = milestones(
            from: start,
            through: elapsedDays,
            completedYears: completedYears,
            calendar: calendar
        )

        return AnniversaryProgress(
            elapsedDays: elapsedDays,
            completedJars: completedYears,
            acornsInCurrentJar: max(acorns, 0),
            currentJarCapacity: max(capacity, 1),
            nextMilestone: nextMilestone(
                start: start,
                current: current,
                elapsedDays: elapsedDays,
                nextAnniversary: nextAnniversary,
                completedYears: completedYears,
                calendar: calendar
            ),
            jarMilestones: jarMilestones(
                from: milestones,
                currentJarStartDay: currentJarStartDay,
                acornCount: max(acorns, 0)
            ),
            todayMilestone: milestones.first(where: { $0.elapsedDay == elapsedDays })
        )
    }

    private static func daysInAnniversaryYear(from start: Date, calendar: Calendar) -> Int {
        guard let nextYear = calendar.date(byAdding: .year, value: 1, to: start) else {
            return 365
        }
        return calendar.dateComponents([.day], from: start, to: nextYear).day ?? 365
    }

    private static func milestones(
        from start: Date,
        through elapsedDays: Int,
        completedYears: Int,
        calendar: Calendar
    ) -> [AnniversaryMilestone] {
        var groupedKinds: [Int: Set<AnniversaryMilestone.Kind>] = [:]
        var dates: [Int: Date] = [:]

        if elapsedDays >= 100 {
            for day in stride(from: 100, through: elapsedDays, by: 100) {
                groupedKinds[day, default: []].insert(.hundredDay(day))
                dates[day] = calendar.date(byAdding: .day, value: day, to: start)
            }
        }

        if completedYears > 0 {
            for year in 1...completedYears {
                guard let date = calendar.date(byAdding: .year, value: year, to: start) else { continue }
                let day = calendar.dateComponents([.day], from: start, to: date).day ?? 0
                groupedKinds[day, default: []].insert(.anniversary(year))
                dates[day] = date
            }
        }

        return groupedKinds.keys.sorted().compactMap { day in
            guard let date = dates[day] else { return nil }
            let kinds = groupedKinds[day, default: []].sorted { lhs, rhs in
                lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            }
            return AnniversaryMilestone(elapsedDay: day, date: date, kinds: kinds)
        }
    }

    private static func jarMilestones(
        from milestones: [AnniversaryMilestone],
        currentJarStartDay: Int,
        acornCount: Int
    ) -> [JarMilestone] {
        milestones.compactMap { milestone in
            let dayInJar: Int

            if milestone.elapsedDay == currentJarStartDay,
               milestone.kinds.contains(where: { kind in
                   if case .anniversary = kind { return true }
                   return false
               }) {
                dayInJar = 1
            } else {
                dayInJar = milestone.elapsedDay - currentJarStartDay
            }

            guard dayInJar > 0, dayInJar <= acornCount else { return nil }
            return JarMilestone(dayInJar: dayInJar, milestone: milestone)
        }
    }

    private static func nextMilestone(
        start: Date,
        current: Date,
        elapsedDays: Int,
        nextAnniversary: Date,
        completedYears: Int,
        calendar: Calendar
    ) -> AnniversaryProgress.Milestone {
        let nextDayCount = ((elapsedDays / 100) + 1) * 100
        let nextDayDate = calendar.date(byAdding: .day, value: nextDayCount, to: start) ?? current
        let daysToDayMilestone = max(
            calendar.dateComponents([.day], from: current, to: nextDayDate).day ?? 0,
            0
        )
        let daysToAnniversary = max(
            calendar.dateComponents([.day], from: current, to: nextAnniversary).day ?? 0,
            0
        )

        if daysToAnniversary <= daysToDayMilestone {
            return .init(
                title: "\(completedYears + 1)주년",
                date: nextAnniversary,
                daysRemaining: daysToAnniversary
            )
        }

        return .init(
            title: "\(nextDayCount)일",
            date: nextDayDate,
            daysRemaining: daysToDayMilestone
        )
    }
}
