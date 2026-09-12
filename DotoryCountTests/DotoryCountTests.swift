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
}
