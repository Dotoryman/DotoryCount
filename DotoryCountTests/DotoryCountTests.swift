import Foundation
import Testing
@testable import DotoryCount

struct DotoryCountTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    @Test("첫날은 D+0이고 도토리가 비어 있다")
    func startDay() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 8, day: 23)))
        let progress = AnniversaryCalculator.progress(from: start, to: start, calendar: calendar)

        #expect(progress.elapsedDays == 0)
        #expect(progress.completedJars == 0)
        #expect(progress.acornsInCurrentJar == 0)
        #expect(progress.counterText == "D+0")
    }

    @Test("1주년이 지나면 가득 찬 병 하나를 만든다")
    func firstAnniversary() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 2025, month: 8, day: 23)))
        let current = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 8)))
        let progress = AnniversaryCalculator.progress(from: start, to: current, calendar: calendar)

        #expect(progress.elapsedDays == 381)
        #expect(progress.completedJars == 1)
        #expect(progress.acornsInCurrentJar == 16)
    }

    @Test("윤년을 달력상의 1주년으로 계산한다")
    func leapYearAnniversary() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 2023, month: 3, day: 1)))
        let current = try #require(calendar.date(from: DateComponents(year: 2024, month: 3, day: 1)))
        let progress = AnniversaryCalculator.progress(from: start, to: current, calendar: calendar)

        #expect(progress.elapsedDays == 366)
        #expect(progress.completedJars == 1)
        #expect(progress.acornsInCurrentJar == 0)
    }

    @Test("미래 날짜는 D-로 표시한다")
    func futureDate() throws {
        let current = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 1)))
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 11)))
        let progress = AnniversaryCalculator.progress(from: start, to: current, calendar: calendar)

        #expect(progress.elapsedDays == -10)
        #expect(progress.counterText == "D-10")
        #expect(progress.nextMilestone.title == "시작일")
    }

    @Test("100일보다 주년이 가까우면 주년을 안내한다")
    func anniversaryBeforeDayMilestone() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 2025, month: 9, day: 20)))
        let current = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 13)))
        let progress = AnniversaryCalculator.progress(from: start, to: current, calendar: calendar)

        #expect(progress.nextMilestone.title == "1주년")
        #expect(progress.nextMilestone.daysRemaining == 7)
    }

    @Test("윤년이 포함된 병의 용량은 366일이다")
    func leapYearJarCapacity() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 2023, month: 9, day: 13)))
        let current = try #require(calendar.date(from: DateComponents(year: 2024, month: 2, day: 29)))
        let progress = AnniversaryCalculator.progress(from: start, to: current, calendar: calendar)

        #expect(progress.currentJarCapacity == 366)
        #expect(progress.acornsInCurrentJar == 169)
    }

    @Test("도토리 배치는 개수가 늘어도 기존 위치를 유지한다")
    func acornLayoutIsStable() {
        let initial = AcornJarLayout.placements(count: 120)
        let expanded = AcornJarLayout.placements(count: 121)

        #expect(Array(expanded.prefix(initial.count)) == initial)
    }

    @Test("윤년의 모든 도토리가 병 안 안전 영역에 배치된다")
    func leapYearAcornsStayInsideJar() {
        let placements = AcornJarLayout.placements(count: 366)

        #expect(placements.count == 366)
        #expect(placements.allSatisfy { placement in
            placement.x - placement.width / 2 >= 0.10
                && placement.x + placement.width / 2 <= 0.90
                && placement.y - placement.height / 2 >= 0.20
                && placement.y + placement.height / 2 <= 0.94
        })
    }

    @Test("잘못된 도토리 수는 안전한 표시 범위로 제한한다")
    func acornLayoutClampsCount() {
        #expect(AcornJarLayout.placements(count: -1).isEmpty)
        #expect(
            AcornJarLayout.placements(count: 1_000).count
                == AcornJarLayout.maximumVisibleCount
        )
    }
}
