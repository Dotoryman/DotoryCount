import SwiftUI

struct AcornJarView: View {
    let acornCount: Int
    let capacity: Int
    var milestones: [JarMilestone] = []
    var latestAcornPresentation: LatestAcornPresentation = .static
    var celebratingMilestone: AnniversaryMilestone?
    var onMilestoneTapped: (AnniversaryMilestone) -> Void = { _ in }

    var body: some View {
        GeometryReader { proxy in
            let placements = AcornJarLayout.placements(dayCount: acornCount)
            let latestPlacement = placements.last?.resolved(in: proxy.size)
            let staticPlacements = latestAcornPresentation == .static
                ? placements[...]
                : placements.dropLast()
            let visualMilestones = visualMilestones(for: placements)
            let goldenIndexes = Set(visualMilestones.map(\.index))

            ZStack {
                jarInterior

                Canvas { context, size in
                    let regularAcorn = context.resolve(Image("AcornSprite"))

                    for (index, placement) in staticPlacements.enumerated() {
                        guard !goldenIndexes.contains(index) else { continue }
                        AcornRenderer.draw(
                            regularAcorn,
                            in: &context,
                            placement: placement.resolved(in: size)
                        )
                    }
                }

                milestoneButtons(visualMilestones, in: proxy.size)

                if latestAcornPresentation == .falling, let latestPlacement {
                    FallingAcornView(
                        placement: latestPlacement,
                        isGolden: goldenIndexes.contains(max(placements.count - 1, 0))
                    )
                }

                frontGlass
            }
            .clipShape(GlassJarShape())
            .overlay { glassEdges }
            .overlay(alignment: .top) { jarRim }
            .shadow(color: Color.black.opacity(0.13), radius: 18, y: 14)
            .shadow(color: AppTheme.glass.opacity(0.22), radius: 6, y: 2)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("유리병")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("acorn-jar")
    }

    private var accessibilityValue: String {
        let goldenCount = milestones.count
        let suffix = goldenCount > 0 ? ", 황금도토리 \(goldenCount)개" : ""
        let animationStatus = latestAcornPresentation == .falling ? ", 도토리 떨어지는 중" : ""
        return "함께한 날 \(acornCount)일, 1년 \(capacity)일\(suffix)\(animationStatus)"
    }

    private var jarInterior: some View {
        GlassJarShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.30),
                        AppTheme.glass.opacity(0.09),
                        Color.white.opacity(0.05),
                        AppTheme.glass.opacity(0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial, in: GlassJarShape())
    }

    private var frontGlass: some View {
        GeometryReader { proxy in
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.68), Color.white.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: proxy.size.width * 0.045, height: proxy.size.height * 0.48)
                    .blur(radius: 0.8)
                    .position(x: proxy.size.width * 0.19, y: proxy.size.height * 0.53)

                Capsule()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: proxy.size.width * 0.022, height: proxy.size.height * 0.25)
                    .blur(radius: 1.2)
                    .position(x: proxy.size.width * 0.26, y: proxy.size.height * 0.43)

                Ellipse()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.78),
                                AppTheme.glass.opacity(0.64),
                                Color.white.opacity(0.20)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 4
                    )
                    .frame(width: proxy.size.width * 0.76, height: proxy.size.height * 0.085)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.91)

                if celebratingMilestone != nil {
                    RadialGradient(
                        colors: [Color.yellow.opacity(0.20), Color.clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: proxy.size.width * 0.38
                    )
                    .blendMode(.screen)
                    .transition(.opacity)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var glassEdges: some View {
        GlassJarShape()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.94),
                        AppTheme.glass.opacity(0.86),
                        Color.white.opacity(0.38),
                        AppTheme.glass.opacity(0.72)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
            )
            .overlay {
                GlassJarShape()
                    .inset(by: 5)
                    .stroke(Color.white.opacity(0.22), lineWidth: 2)
            }
    }

    private var jarRim: some View {
        GeometryReader { proxy in
            ZStack {
                Capsule()
                    .fill(AppTheme.glass.opacity(0.16))
                    .frame(width: proxy.size.width * 0.58, height: proxy.size.height * 0.075)

                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white, AppTheme.glass, Color.white.opacity(0.82)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 5
                    )
                    .frame(width: proxy.size.width * 0.58, height: proxy.size.height * 0.075)

                Capsule()
                    .stroke(Color.white.opacity(0.72), lineWidth: 2)
                    .frame(width: proxy.size.width * 0.50, height: proxy.size.height * 0.038)
            }
            .position(x: proxy.size.width / 2, y: 6)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func milestoneButtons(
        _ visualMilestones: [VisualMilestone],
        in size: CGSize
    ) -> some View {
        ForEach(visualMilestones) { item in
            let placement = item.placement.resolved(in: size)
            let spriteSize = placement.spriteSize

            Button {
                onMilestoneTapped(item.milestone)
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.30), Color.yellow.opacity(0.06), Color.clear],
                                center: .center,
                                startRadius: 1,
                                endRadius: max(spriteSize.width, spriteSize.height)
                            )
                        )
                        .blendMode(.screen)

                    Image("GoldenAcornSprite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: spriteSize.width, height: spriteSize.height)
                        .rotationEffect(placement.rotation)
                        .shadow(color: Color.yellow.opacity(0.35), radius: 3, y: 1)
                }
                .frame(width: max(placement.size.width * 1.8, 44), height: max(placement.size.height * 1.4, 44))
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .position(placement.center)
            .accessibilityLabel("황금도토리 \(item.milestone.title)")
            .accessibilityHint("기념일 내용을 확인합니다")
        }
    }

    private func visualMilestones(for placements: [AcornPlacement]) -> [VisualMilestone] {
        var usedIndexes = Set<Int>()

        return milestones.compactMap { jarMilestone in
            let index = AcornJarLayout.visualIndex(forDay: jarMilestone.dayInJar)
            guard placements.indices.contains(index), usedIndexes.insert(index).inserted else { return nil }
            return VisualMilestone(
                index: index,
                placement: placements[index],
                milestone: jarMilestone.milestone
            )
        }
    }
}

enum LatestAcornPresentation: Equatable {
    case hidden
    case falling
    case `static`
}

nonisolated struct AcornPlacement: Equatable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let rotation: Double

    func resolved(in size: CGSize) -> ResolvedAcornPlacement {
        ResolvedAcornPlacement(
            center: CGPoint(x: size.width * x, y: size.height * y),
            size: CGSize(width: size.width * width, height: size.height * height),
            rotation: .degrees(rotation)
        )
    }
}

struct ResolvedAcornPlacement {
    let center: CGPoint
    let size: CGSize
    let rotation: Angle

    var spriteSize: CGSize {
        let side = min(size.width, size.height)
        return CGSize(width: side, height: side)
    }
}

private struct VisualMilestone: Identifiable {
    let index: Int
    let placement: AcornPlacement
    let milestone: AnniversaryMilestone

    var id: Int { milestone.id }
}

enum AcornJarLayout {
    static let exactDayLimit = 14
    static let daysPerVisualAcorn = 7

    private static let rowCapacities = [9, 7, 9, 7, 9, 7, 9, 7]

    static var maximumVisibleCount: Int {
        rowCapacities.reduce(0, +)
    }

    static func displayedCount(for dayCount: Int) -> Int {
        let safeCount = max(dayCount, 0)
        guard safeCount > exactDayLimit else { return safeCount }

        let groupedDays = safeCount - exactDayLimit
        let weeklyAcorns = (groupedDays + daysPerVisualAcorn - 1) / daysPerVisualAcorn
        return min(exactDayLimit + weeklyAcorns, maximumVisibleCount)
    }

    static func visualIndex(forDay day: Int) -> Int {
        let safeDay = max(day, 1)
        guard safeDay > exactDayLimit else { return safeDay - 1 }
        return min(
            exactDayLimit + (safeDay - exactDayLimit - 1) / daysPerVisualAcorn,
            maximumVisibleCount - 1
        )
    }

    static func addsVisualAcorn(onDay day: Int) -> Bool {
        guard day > 0 else { return false }
        guard day > exactDayLimit else { return true }
        return (day - exactDayLimit - 1).isMultiple(of: daysPerVisualAcorn)
    }

    static func placements(dayCount: Int) -> [AcornPlacement] {
        placements(visibleCount: displayedCount(for: dayCount))
    }

    static func placements(visibleCount: Int) -> [AcornPlacement] {
        let count = min(max(visibleCount, 0), maximumVisibleCount)
        let cellHeight = 0.50 / Double(rowCapacities.count)

        return (0..<count).map { index in
            let rowPosition = rowPosition(for: index)
            let row = rowPosition.row
            let capacity = rowCapacities[row]
            let orderedSlot = centerOutSlots(for: capacity)[rowPosition.indexInRow]
            let slotOffset = Double(orderedSlot) - Double(capacity - 1) / 2
            let horizontalSpacing = 0.082
            let rowDrift = centeredNoise(index: row, salt: 149) * 0.012
            let jitterX = centeredNoise(index: index, salt: 17) * 0.014
            let jitterY = centeredNoise(index: index, salt: 43) * cellHeight * 0.18
            let scale = 0.86 + unitNoise(index: index, salt: 71) * 0.24

            return AcornPlacement(
                x: 0.50 + slotOffset * horizontalSpacing + rowDrift + jitterX,
                y: 0.88 - (Double(row) + 0.5) * cellHeight + jitterY,
                width: 0.15 * scale,
                height: 0.18 * scale,
                rotation: centeredNoise(index: index, salt: 101) * 38
            )
        }
    }

    private static func rowPosition(for index: Int) -> (row: Int, indexInRow: Int) {
        var remaining = index

        for (row, capacity) in rowCapacities.enumerated() {
            if remaining < capacity {
                return (row, remaining)
            }
            remaining -= capacity
        }

        return (rowCapacities.count - 1, rowCapacities.last.map { $0 - 1 } ?? 0)
    }

    private static func centerOutSlots(for capacity: Int) -> [Int] {
        let center = Double(capacity - 1) / 2
        return (0..<capacity).sorted { lhs, rhs in
            let lhsDistance = abs(Double(lhs) - center)
            let rhsDistance = abs(Double(rhs) - center)
            if lhsDistance == rhsDistance {
                return lhs < rhs
            }
            return lhsDistance < rhsDistance
        }
    }

    private static func centeredNoise(index: Int, salt: UInt64) -> Double {
        unitNoise(index: index, salt: salt) * 2 - 1
    }

    private static func unitNoise(index: Int, salt: UInt64) -> Double {
        var value = UInt64(index) &* 6_364_136_223_846_793_005 &+ salt
        value ^= value >> 30
        value &*= 1_379_878_784_942_060_787
        value ^= value >> 27
        return Double(value % 10_000) / 9_999
    }
}

private struct FallingAcornView: View {
    let placement: ResolvedAcornPlacement
    let isGolden: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSettled = false

    var body: some View {
        let spriteSize = placement.spriteSize

        Image(isGolden ? "GoldenAcornSprite" : "AcornSprite")
            .resizable()
            .scaledToFit()
            .frame(width: spriteSize.width, height: spriteSize.height)
            .shadow(color: Color.black.opacity(0.22), radius: 2, y: 2)
            .position(placement.center)
            .offset(y: reduceMotion || isSettled ? 0 : -(placement.center.y + placement.size.height * 3))
            .rotationEffect(isSettled ? placement.rotation : placement.rotation - .degrees(95))
            .scaleEffect(isSettled ? 1 : (reduceMotion ? 0.9 : 1.10))
            .opacity(isSettled ? 1 : (reduceMotion ? 0 : 1))
            .task {
                await Task.yield()

                if reduceMotion {
                    withAnimation(.easeOut(duration: 0.24)) {
                        isSettled = true
                    }
                } else {
                    withAnimation(.spring(response: 0.86, dampingFraction: 0.67)) {
                        isSettled = true
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

private enum AcornRenderer {
    static func draw(
        _ image: GraphicsContext.ResolvedImage,
        in context: inout GraphicsContext,
        placement: ResolvedAcornPlacement
    ) {
        let side = placement.spriteSize.width

        context.drawLayer { layer in
            layer.translateBy(x: placement.center.x, y: placement.center.y)
            layer.rotate(by: placement.rotation)
            layer.addFilter(.shadow(color: Color.black.opacity(0.24), radius: 2, x: 0, y: 2))
            layer.draw(
                image,
                in: CGRect(
                    x: -side / 2,
                    y: -side / 2,
                    width: side,
                    height: side
                )
            )
        }
    }
}

private struct GlassJarShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        var path = Path()
        let neckWidth = rect.width * 0.52
        let neckLeft = rect.midX - neckWidth / 2
        let neckRight = rect.midX + neckWidth / 2
        let shoulderY = rect.height * 0.24
        let baseY = rect.maxY - rect.height * 0.035

        path.move(to: CGPoint(x: neckLeft, y: rect.minY + 7))
        path.addLine(to: CGPoint(x: neckRight, y: rect.minY + 7))
        path.addLine(to: CGPoint(x: neckRight, y: rect.height * 0.12))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 7, y: shoulderY),
            control1: CGPoint(x: neckRight, y: rect.height * 0.18),
            control2: CGPoint(x: rect.maxX - 7, y: rect.height * 0.15)
        )
        path.addLine(to: CGPoint(x: rect.maxX - 7, y: rect.maxY - rect.height * 0.13))
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.14, y: baseY),
            control1: CGPoint(x: rect.maxX - 7, y: rect.maxY - rect.height * 0.06),
            control2: CGPoint(x: rect.maxX - rect.width * 0.08, y: baseY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.14, y: baseY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + 7, y: rect.maxY - rect.height * 0.13),
            control1: CGPoint(x: rect.minX + rect.width * 0.08, y: baseY),
            control2: CGPoint(x: rect.minX + 7, y: rect.maxY - rect.height * 0.06)
        )
        path.addLine(to: CGPoint(x: rect.minX + 7, y: shoulderY))
        path.addCurve(
            to: CGPoint(x: neckLeft, y: rect.height * 0.12),
            control1: CGPoint(x: rect.minX + 7, y: rect.height * 0.15),
            control2: CGPoint(x: neckLeft, y: rect.height * 0.18)
        )
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> GlassJarShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

#Preview("사실적인 도토리 병") {
    AcornJarView(
        acornCount: 116,
        capacity: 365,
        milestones: [
            JarMilestone(
                dayInJar: 100,
                milestone: AnniversaryMilestone(
                    elapsedDay: 100,
                    date: .now,
                    kinds: [.hundredDay(100)]
                )
            )
        ],
        latestAcornPresentation: .falling
    )
    .frame(width: 250, height: 320)
    .padding(32)
    .background(AppTheme.background)
}

#Preview("1년 구간") {
    AcornJarView(acornCount: 364, capacity: 365)
        .frame(width: 250, height: 320)
        .padding(32)
        .background(AppTheme.background)
}
