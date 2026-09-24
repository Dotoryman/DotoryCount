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
        let initial = AcornJarLayout.placements(visibleCount: 40)
        let expanded = AcornJarLayout.placements(visibleCount: 41)

        #expect(Array(expanded.prefix(initial.count)) == initial)
    }

    @Test("1년은 최대 64개의 사실적인 도토리로 촘촘하게 표현한다")
    func yearlyDisplayScaleUsesDenseIntervals() {
        #expect(AcornJarLayout.displayedCount(for: 0) == 0)
        #expect(AcornJarLayout.displayedCount(for: 14) == 14)
        #expect(AcornJarLayout.displayedCount(for: 15) == 15)
        #expect(AcornJarLayout.displayedCount(for: 21) == 15)
        #expect(AcornJarLayout.displayedCount(for: 22) == 16)
        #expect(AcornJarLayout.displayedCount(for: 364) == 64)
    }

    @Test("모든 표현용 도토리가 병 안 안전 영역에 배치된다")
    func visualAcornsStayInsideJar() {
        let placements = AcornJarLayout.placements(visibleCount: 64)

        #expect(placements.count == 64)
        #expect(placements.allSatisfy { placement in
            placement.x - placement.width / 2 >= 0.03
                && placement.x + placement.width / 2 <= 0.97
                && placement.y - placement.height / 2 >= 0.20
                && placement.y + placement.height / 2 <= 0.97
        })
    }

    @Test("도토리 스프라이트는 원본 비율을 유지하는 정사각형에 그린다")
    func acornSpritePreservesAspectRatio() {
        let placement = AcornJarLayout.placements(visibleCount: 1)[0]
        let resolved = placement.resolved(in: CGSize(width: 250, height: 320))

        #expect(resolved.spriteSize.width == resolved.spriteSize.height)
        #expect(resolved.spriteSize.width == min(resolved.size.width, resolved.size.height))
    }

    @Test("잘못된 도토리 수는 안전한 표시 범위로 제한한다")
    func acornLayoutClampsCount() {
        #expect(AcornJarLayout.placements(dayCount: -1).isEmpty)
        #expect(
            AcornJarLayout.placements(dayCount: 1_000).count
                == AcornJarLayout.maximumVisibleCount
        )
    }

    @Test("100일은 현재 병의 황금도토리로 계산한다")
    func hundredDayCreatesGoldenAcorn() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let current = try #require(calendar.date(byAdding: .day, value: 100, to: start))
        let progress = AnniversaryCalculator.progress(from: start, to: current, calendar: calendar)

        #expect(progress.todayMilestone?.title == "100일")
        #expect(progress.jarMilestones.count == 1)
        #expect(progress.jarMilestones.first?.dayInJar == 100)
        #expect(AcornJarLayout.visualIndex(forDay: 100) == 26)
    }

    @Test("주년 다음 날 첫 도토리는 이전 주년을 황금으로 간직한다")
    func anniversaryStartsWithGoldenAcorn() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 2025, month: 9, day: 19)))
        let current = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 20)))
        let progress = AnniversaryCalculator.progress(from: start, to: current, calendar: calendar)

        #expect(progress.completedJars == 1)
        #expect(progress.acornsInCurrentJar == 1)
        #expect(progress.jarMilestones.first?.dayInJar == 1)
        #expect(progress.jarMilestones.first?.milestone.title == "1주년")
    }

    @Test("사진 병은 초반 8일을 하루씩, 연말까지 36단계로 채운다")
    func photographicJarStages() {
        #expect(PhotographicJarStages.stage(for: -1, capacity: 365) == 0)
        for day in 0...8 {
            #expect(PhotographicJarStages.stage(for: day, capacity: 365) == day)
        }
        #expect(PhotographicJarStages.stage(for: 9, capacity: 365) == 9)
        #expect(PhotographicJarStages.stage(for: 364, capacity: 365) == 36)
        #expect(PhotographicJarStages.stage(for: 365, capacity: 366) == 36)
        let stages = (0...365).map { PhotographicJarStages.stage(for: $0, capacity: 366) }
        #expect(stages == stages.sorted())
        #expect(Set(stages).count == 37)
    }

    @Test("36개 도토리는 병 내부에 다양한 각도로 안정적으로 놓인다")
    func photographicJarPlacements() {
        let placements = PhotographicJarStages.placements
        #expect(placements.count == 36)
        #expect(Set(placements.map { Int($0.angle / 15) }).count > 5)
        #expect(placements.allSatisfy {
            $0.x - $0.radius > 160 && $0.x + $0.radius < 780
                && $0.y - $0.radius > 630 && $0.y + $0.radius < 1330
        })
        for first in placements.indices {
            for second in placements.indices where second > first {
                let dx = placements[first].x - placements[second].x
                let dy = placements[first].y - placements[second].y
                let clearance = placements[first].radius + placements[second].radius
                #expect(dx * dx + dy * dy >= clearance * clearance - 1)
            }
        }
        #expect(Set(placements.map(\.variant)) == Set([0, 1, 2]))
    }

    @Test("직접 입력 날짜는 숫자와 구분자를 받고 존재하지 않는 날짜는 거부한다")
    func directDateInput() throws {
        let leapDate = try #require(StartDateInput.parse("2020.02.29", calendar: calendar))
        #expect(StartDateInput.format(leapDate, calendar: calendar) == "2020.02.29")
        #expect(StartDateInput.parse("20200229", calendar: calendar) == leapDate)
        #expect(StartDateInput.parse("2021.02.29", calendar: calendar) == nil)
        #expect(StartDateInput.parse("2026.13.01", calendar: calendar) == nil)
        #expect(StartDateInput.parse("2026.09", calendar: calendar) == nil)
    }
}
