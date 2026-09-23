import SwiftUI

enum JarDropTiming {
    static var duration: TimeInterval {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-slow-animation") ? 3.5 : 2.25
    }
}

/// The exact day count stays in AnniversaryProgress. Thirty-six visual additions
/// give the photographic jar a readable, steadily growing silhouette.
enum PhotographicJarStages {
    static let maximumStage = 36
    static let exactDays = 8

    static func stage(for day: Int, capacity: Int) -> Int {
        let day = min(max(day, 0), max(capacity - 1, 0))
        guard day > exactDays else { return day }
        let remainingDays = max(capacity - exactDays - 1, 1)
        let remainingStages = maximumStage - exactDays
        return min(
            exactDays + 1 + (day - exactDays - 1) * remainingStages / remainingDays,
            maximumStage
        )
    }

    struct Placement: Equatable {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let angle: Double
    }

    // The glass is 941 × 1672. Positions are in that artboard's coordinates.
    // Each row sits partly behind the row above it, with deterministic variation.
    static let placements: [Placement] = {
        let rowCounts = [7, 7, 6, 6, 5, 5]
        var result: [Placement] = []
        for (row, count) in rowCounts.enumerated() {
            let spacing: CGFloat = row < 2 ? 75 : 82
            let order = (0..<count).sorted {
                abs(CGFloat($0) - CGFloat(count - 1) / 2) < abs(CGFloat($1) - CGFloat(count - 1) / 2)
            }
            for slot in order {
                let index = result.count
                let xNoise = noise(index, salt: 11) * 21
                let yNoise = noise(index, salt: 47) * 20
                let angle = Double(noise(index, salt: 83) * 112)
                let size = 210 + noise(index, salt: 29) * 20
                result.append(Placement(
                    x: 470 + (CGFloat(slot) - CGFloat(count - 1) / 2) * spacing + xNoise,
                    y: 1195 - CGFloat(row) * 86 + yNoise,
                    size: size,
                    angle: angle
                ))
            }
        }
        return result
    }()

    private static func noise(_ index: Int, salt: UInt64) -> CGFloat {
        var value = UInt64(index + 1) &* 6_364_136_223_846_793_005 &+ salt
        value ^= value >> 30
        value &*= 1_379_878_784_942_060_787
        value ^= value >> 27
        return CGFloat(value % 10_000) / 4_999.5 - 1
    }
}

struct PhotographicJarScene: View {
    let progress: AnniversaryProgress
    let replayID: Int
    let reduceMotion: Bool

    @State private var dropStartedAt = Date.distantPast
    @State private var isAnimating = false
    @State private var finishTask: Task<Void, Never>?
    @State private var motionVariant = 0

    private var stage: Int {
        PhotographicJarStages.stage(
            for: progress.acornsInCurrentJar,
            capacity: progress.currentJarCapacity
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let width = min(
                geometry.size.width * 1.12,
                max(geometry.size.height - 310, 230) * 941 / 880
            )
            let scale = width / 941
            let height = 1672 * scale

            jarArtboard(width: width, height: height, scale: scale)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2 - 12 - 134 * scale
                )
        }
        .accessibilityHidden(true)
        .onChange(of: replayID) { _, _ in replay() }
        .onDisappear { finishTask?.cancel() }
    }

    private func jarArtboard(width: CGFloat, height: CGFloat, scale: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Image("JarEmptyBase")
                .resizable()
                .frame(width: width, height: height)

            ForEach(0..<max(stage - 1, 0), id: \.self) { index in
                acorn(at: PhotographicJarStages.placements[index],
                      golden: isGolden(index: index), scale: scale)
            }

            if stage > 0 {
                let placement = PhotographicJarStages.placements[stage - 1]
                TimelineView(.animation(minimumInterval: 1.0 / 60, paused: !isAnimating)) { timeline in
                    let elapsed = timeline.date.timeIntervalSince(dropStartedAt)
                    let motion = isAnimating ? min(max(elapsed / JarDropTiming.duration, 0), 1) : 1
                    let offset = fallingOffset(placement, progress: motion)
                    acorn(at: placement,
                          golden: isGolden(index: stage - 1),
                          scale: scale,
                          offset: offset,
                          extraRotation: fallingRotation(progress: motion))
                }
            }

            Image("JarGlassFront")
                .resizable()
                .frame(width: width, height: height)
                .allowsHitTesting(false)
        }
        .frame(width: width, height: height)
    }

    private func acorn(
        at placement: PhotographicJarStages.Placement,
        golden: Bool,
        scale: CGFloat,
        offset: CGSize = .zero,
        extraRotation: Double = 0
    ) -> some View {
        Image(golden ? "GoldenAcornSprite" : "AcornSprite")
            .resizable()
            .scaledToFit()
            .frame(width: placement.size * scale, height: placement.size * scale)
            .rotationEffect(.degrees(placement.angle + extraRotation))
            .shadow(color: .brown.opacity(0.25), radius: 4 * scale, y: 5 * scale)
            .position(
                x: (placement.x + offset.width) * scale,
                y: (placement.y + offset.height) * scale
            )
    }

    private func isGolden(index: Int) -> Bool {
        progress.jarMilestones.contains { milestone in
            PhotographicJarStages.stage(
                for: milestone.dayInJar,
                capacity: progress.currentJarCapacity
            ) == index + 1
        }
    }

    private func fallingOffset(
        _ placement: PhotographicJarStages.Placement,
        progress: Double
    ) -> CGSize {
        guard !reduceMotion else { return .zero }
        let direction: CGFloat = motionVariant.isMultiple(of: 2) ? -1 : 1
        let landingDrift = CGFloat(motionVariant % 5 - 2) * 6
        guard progress < 1 else { return CGSize(width: landingDrift, height: 0) }
        let entryX = 470 + CGFloat(motionVariant % 5 - 2) * 18
        let entryOffset = entryX - placement.x
        let target = placement.y
        let t = progress

        if t < 0.57 {
            let p = CGFloat(t / 0.57)
            return CGSize(
                width: entryOffset * (1 - p * p) + sin(p * .pi) * 12 * direction,
                height: (300 - target) * (1 - p * p) - 19
            )
        }
        if t < 0.75 {
            let p = CGFloat((t - 0.57) / 0.18)
            return CGSize(
                width: sin(p * .pi) * 17 * direction,
                height: -19 - sin(p * .pi) * CGFloat(20 + motionVariant % 4 * 7)
            )
        }
        let p = CGFloat((t - 0.75) / 0.25)
        return CGSize(width: sin(p * .pi) * 11 * direction + landingDrift * p,
                      height: -19 * (1 - p) * (1 - p))
    }

    private func fallingRotation(progress: Double) -> Double {
        guard !reduceMotion else { return 0 }
        let landingAngle = Double(motionVariant % 7 - 3) * 7
        guard progress < 1 else { return landingAngle }
        let direction = motionVariant.isMultiple(of: 2) ? -1.0 : 1.0
        let turns = Double(1 + motionVariant % 3)
        return direction * (1 - progress) * turns * 230
            + sin(progress * .pi * 3) * 12 * (1 - progress)
            + landingAngle
    }

    private func replay() {
        finishTask?.cancel()
        guard stage > 0, !reduceMotion else {
            isAnimating = false
            return
        }
        motionVariant = (replayID + progress.elapsedDays * 7) % 12
        dropStartedAt = .now
        isAnimating = true
        finishTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(JarDropTiming.duration))
            guard !Task.isCancelled else { return }
            isAnimating = false
        }
    }
}
