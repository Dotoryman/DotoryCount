import Foundation

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
                )
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
            )
        )
    }

    private static func daysInAnniversaryYear(from start: Date, calendar: Calendar) -> Int {
        guard let nextYear = calendar.date(byAdding: .year, value: 1, to: start) else {
            return 365
        }
        return calendar.dateComponents([.day], from: start, to: nextYear).day ?? 365
    }

    private static func nextMilestone(
        start: Date,
        current: Date,
        elapsedDays: Int,
        nextAnniversary: Date,
        completedYears: Int,
        calendar: Calendar
    ) -> AnniversaryProgress.Milestone {
        let dayMilestones = [100, 200, 300, 400, 500, 1_000]
        let nextDayCount = dayMilestones.first(where: { $0 > elapsedDays })
            ?? ((elapsedDays / 100) + 1) * 100
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
