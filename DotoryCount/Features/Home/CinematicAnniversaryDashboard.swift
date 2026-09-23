import AVFoundation
import SwiftUI

/// An icon-led visual preview. The exact date remains in the data model and footer;
/// the bundled film is a single art-direction study, not yet a per-day fill state.
struct CinematicAnniversaryDashboard: View {
    let anniversary: Anniversary
    let replayToken: Int
    let editAction: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedMilestone: AnniversaryMilestone?
    @State private var replayID = 0
    @State private var isDropping = false
    @State private var dropTask: Task<Void, Never>?

    private var progress: AnniversaryProgress {
        AnniversaryCalculator.progress(from: anniversary.startDate)
    }

    var body: some View {
        ZStack {
            Color(red: 1, green: 0.977, blue: 0.937)
                .ignoresSafeArea()

            Image("JarPreviewStill")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            if !reduceMotion {
                JarMotionPlayerView(replayID: replayID)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }

            Button(action: replay) {
                Color.clear
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("유리병 속 도토리 영상")
            .accessibilityValue("함께한 날 \(progress.acornsInCurrentJar)일" + (isDropping ? ", 도토리 떨어지는 중" : ""))
            .accessibilityIdentifier("acorn-jar")

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 26)
                    .padding(.top, 16)

                Spacer(minLength: 0)

                footer
                    .padding(.horizontal, 26)
                    .padding(.bottom, 16)
            }

        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .sheet(item: $selectedMilestone) { milestone in
            MilestoneDetailView(milestone: milestone)
        }
        .onAppear { replay() }
        .onChange(of: replayToken) { _, _ in replay() }
        .onChange(of: scenePhase) { previous, current in
            guard previous != .active, current == .active else { return }
            replay()
        }
        .onChange(of: selectedMilestone?.id) { previous, current in
            guard previous != nil, current == nil else { return }
            replay()
        }
        .onDisappear { dropTask?.cancel() }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("DOTORY COUNT")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(AppTheme.accent)
                Text(anniversary.title)
                    .font(.system(size: 27, weight: .semibold, design: .serif))
                    .lineLimit(2)
                Text(anniversary.startDate.formatted(date: .long, time: .omitted))
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer(minLength: 12)
            Button(action: editAction) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 19, weight: .medium))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.86), in: Circle())
            }
            .accessibilityLabel("기념일 수정")
            .accessibilityIdentifier("edit-anniversary-button")
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(progress.counterText)
                    .font(.system(size: 36, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .accessibilityIdentifier("day-counter")
                Text("\(progress.completedJars + 1)번째 병 · \(progress.acornsInCurrentJar)일")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer(minLength: 0)
            }
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .foregroundStyle(AppTheme.accent)
                Text(progress.todayMilestone.map { "오늘은 \($0.title)" } ?? "다음 황금도토리 · \(progress.nextMilestone.title)")
                    .font(.system(size: 13, weight: .semibold))
                Spacer(minLength: 0)
                if let milestone = progress.todayMilestone {
                    Button("황금도토리 \(milestone.title)") {
                        selectedMilestone = milestone
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .accessibilityIdentifier("milestone-celebration")
                }
            }
            Text("영상 시안 · 화면을 탭하면 다시 재생됩니다")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(15)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 19))
    }

    private func replay() {
        dropTask?.cancel()
        guard !reduceMotion else {
            isDropping = false
            return
        }
        replayID &+= 1
        isDropping = true
        dropTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            isDropping = false
        }
    }
}

private struct JarMotionPlayerView: UIViewRepresentable {
    let replayID: Int

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> PlayerSurface {
        let view = PlayerSurface()
        guard let url = Bundle.main.url(forResource: "JarMotionPreview", withExtension: "mp4") else {
            return view
        }
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .pause
        view.playerLayer.player = player
        context.coordinator.player = player
        return view
    }

    func updateUIView(_ view: PlayerSurface, context: Context) {
        guard context.coordinator.lastReplayID != replayID else { return }
        context.coordinator.lastReplayID = replayID
        context.coordinator.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        context.coordinator.player?.play()
    }

    final class Coordinator {
        var player: AVPlayer?
        var lastReplayID: Int?
    }

    final class PlayerSurface: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

        override init(frame: CGRect) {
            super.init(frame: frame)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.backgroundColor = UIColor(red: 1, green: 0.977, blue: 0.937, alpha: 1).cgColor
            isUserInteractionEnabled = false
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}
