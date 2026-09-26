import SwiftUI

/// The jar is the primary scene; dates and milestones stay as supporting detail.
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

            PhotographicJarScene(
                progress: progress,
                replayID: replayID,
                reduceMotion: reduceMotion
            )
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 26)
                    .padding(.top, 16)

                Spacer(minLength: 0)

                footer
                    .padding(.horizontal, 26)
                    .padding(.bottom, 16)
            }

            GeometryReader { geometry in
                Button(action: replay) {
                    Rectangle()
                        .fill(.clear)
                        .frame(
                            width: geometry.size.width,
                            height: max(160, min(geometry.size.height - 290, geometry.size.width * 1.12))
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 12)
                .accessibilityLabel("유리병 속 도토리")
                .accessibilityValue("함께한 날 \(progress.acornsInCurrentJar)일" + (isDropping ? ", 도토리 떨어지는 중" : ""))
                .accessibilityIdentifier("acorn-jar")
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
            }
            .modifier(GlassActionStyle())
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
            Text("병을 탭하면 오늘의 도토리가 다시 떨어져요")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(15)
        .modifier(GlassInformationPanel())
    }

    private func replay() {
        dropTask?.cancel()
        guard !reduceMotion, progress.acornsInCurrentJar > 0 else {
            isDropping = false
            return
        }
        replayID &+= 1
        isDropping = true
        dropTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(JarDropTiming.duration))
            guard !Task.isCancelled else { return }
            isDropping = false
        }
    }
}
