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
        let radius: CGFloat
        let size: CGFloat
        let angle: Double
        let variant: Int
        let depth: CGFloat
    }

    // Drop differently sized disks into a shallow curved jar floor. Each disk
    // rests on the floor or a previously settled disk, rather than a fixed row.
    // The glass is 941 × 1672; all coordinates use that artboard.
    static let placements: [Placement] = {
        var result: [Placement] = []
        for index in 0..<maximumStage {
            // The PNGs include soft transparent edges. Their visible bodies are
            // smaller than their frames, so a tighter collision hull lets the
            // silhouettes touch like objects in a real pile.
            let radius = 36 + noise(index, salt: 29) * 4
            let preferredX = 470 + noise(index, salt: 11) * 225
            var bestX: CGFloat = 470
            var bestY: CGFloat = 0
            var bestScore = -CGFloat.infinity

            for step in 0...102 {
                let x = CGFloat(215 + step * 5)
                let distanceFromCenter = x - 470
                let floorY = 1290 - 0.00065 * distanceFromCenter * distanceFromCenter
                var y = floorY - radius

                for previous in result {
                    let dx = x - previous.x
                    let clearance = radius + previous.radius
                    if abs(dx) < clearance {
                        let contactRise = sqrt(clearance * clearance - dx * dx)
                        y = min(y, previous.y - contactRise)
                    }
                }

                // Gravity dominates, with a small deterministic preference for
                // different landing sides so the pile is not mirror-symmetric.
                let score = y - abs(x - preferredX) * 0.045
                if score > bestScore {
                    bestScore = score
                    bestX = x
                    bestY = y
                }
            }

            let variant = min(Int((noise(index, salt: 153) + 1) * 1.5), 2)
            let depth = noise(index, salt: 79)
            result.append(Placement(
                x: bestX,
                y: bestY,
                radius: radius,
                size: variant == 0 ? 190 : 148,
                angle: Double(noise(index, salt: 83) * 155),
                variant: variant,
                depth: depth
            ))
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
        let settledIndices = (0..<max(stage - 1, 0)).sorted {
            PhotographicJarStages.placements[$0].depth < PhotographicJarStages.placements[$1].depth
        }
        return ZStack(alignment: .topLeading) {
            Image("JarEmptyBase")
                .resizable()
                .frame(width: width, height: height)

            Ellipse()
                .fill(.black.opacity(0.32))
                .frame(width: 510 * scale, height: 82 * scale)
                .blur(radius: 18 * scale)
                .position(x: 470 * scale, y: 1282 * scale)

            Ellipse()
                .fill(.brown.opacity(0.08))
                .frame(width: 570 * scale, height: 440 * scale)
                .blur(radius: 54 * scale)
                .position(x: 470 * scale, y: 1130 * scale)

            ZStack(alignment: .topLeading) {
                ForEach(settledIndices, id: \.self) { index in
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
            }
            .frame(width: width, height: height)
            .mask(
                JarInteriorFloorMask()
                    .fill(.white)
                    .blur(radius: 18 * scale)
                    .frame(width: width, height: height)
            )

            Image("JarGlassFront")
                .resizable()
                .frame(width: width, height: height)
                .allowsHitTesting(false)

            Ellipse()
                .fill(.black.opacity(0.15))
                .frame(width: 500 * scale, height: 42 * scale)
                .blur(radius: 17 * scale)
                .position(x: 470 * scale, y: 1283 * scale)
                .allowsHitTesting(false)

            LinearGradient(
                colors: [.clear, .white.opacity(0.035), .cyan.opacity(0.07)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 625 * scale, height: 570 * scale)
            .clipShape(RoundedRectangle(cornerRadius: 72 * scale))
            .position(x: 470 * scale, y: 1000 * scale)
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
        let centerX = (placement.x + offset.width) * scale
        let centerY = (placement.y + offset.height) * scale
        let imageName = golden ? "GoldenAcornSprite" :
            (placement.variant == 0 ? "AcornSprite" : placement.variant == 1 ? "AcornSide" : "AcornBack")

        return ZStack(alignment: .topLeading) {
            Ellipse()
                .fill(.black.opacity(0.19 + 0.08 * Double(placement.depth + 1) / 2))
                .frame(width: placement.radius * 2.3 * scale, height: placement.radius * 0.9 * scale)
                .blur(radius: 9 * scale)
                .position(x: centerX + 6 * scale, y: centerY + 24 * scale)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: (golden ? 160 : placement.size) * scale,
                    height: (golden ? 160 : placement.size) * scale
                )
                .rotationEffect(.degrees(placement.angle + extraRotation))
                .brightness(Double(placement.depth) * 0.045)
                .shadow(color: .black.opacity(0.30), radius: 5 * scale, x: 3 * scale, y: 6 * scale)
                .position(x: centerX, y: centerY)
        }
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

/// The front half of the thick glass base must hide any nut silhouette that
/// passes below the inner floor. The curve follows the jar's photographed oval.
private struct JarInteriorFloorMask: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = rect.width / 941
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        for step in stride(from: 941, through: 0, by: -5) {
            let x = CGFloat(step)
            let distance = x - 470
            let floorY = 1284 - 0.00055 * distance * distance
            path.addLine(to: CGPoint(x: x * scale, y: floorY * scale))
        }
        path.addLine(to: CGPoint(x: 0, y: (1284 - 0.00055 * 470 * 470) * scale))
        path.closeSubpath()
        return path
    }
}
