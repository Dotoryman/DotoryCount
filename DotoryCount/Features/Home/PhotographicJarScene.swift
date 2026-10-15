import SwiftUI


enum JarDropTiming {
    static var duration: TimeInterval {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-slow-animation") ? 3.5 : 2.25
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
        PhotographicJarStages.stage(for: progress.acornsInCurrentJar, capacity: progress.currentJarCapacity)
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60, paused: !isAnimating)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(dropStartedAt)
            let motion = isAnimating ? min(max(elapsed / JarDropTiming.duration, 0), 1) : 1
            let offset = stage > 0
                ? fallingOffset(PhotographicJarStages.placements[stage - 1], progress: motion)
                : .zero
            JarArtworkView(progress: progress, latestOffset: offset,
                           latestRotation: fallingRotation(progress: motion))
        }
        .accessibilityHidden(true)
        .onChange(of: replayID) { _, _ in replay() }
        .onDisappear { finishTask?.cancel() }
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
