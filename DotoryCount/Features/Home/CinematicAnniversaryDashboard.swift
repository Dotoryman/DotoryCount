import SwiftUI

/// An object-first home: one photograph, one replay action, one quiet day count.
struct CinematicAnniversaryDashboard: View {
    let anniversary: Anniversary
    let replayToken: Int
    let editAction: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicType
    @ScaledMetric(relativeTo: .largeTitle) private var counterSize = 42
    @State private var milestoneSheet: MilestoneSheet?
    @State private var replayID = 0
    @State private var isDropping = false
    @State private var dropTask: Task<Void, Never>?

    private var progress: AnniversaryProgress {
        AnniversaryCalculator.progress(from: anniversary.startDate)
    }

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.periodic(from: .now, by: 60)) { _ in
                ScrollView {
                    VStack(spacing: 0) {
                        topBar
                            .padding(.bottom, 14)
                        introduction
                        jarExhibit(height: dynamicType.isAccessibilitySize ? 280 :
                            max(270, min(410, geometry.size.height - 340)))
                        replayButton
                            .padding(.top, 2)
                        daySummary
                            .padding(.top, 18)
                            .padding(.bottom, 22)
                        milestoneCard
                            .padding(.horizontal, AppTheme.horizontalPadding)
                            .padding(.bottom, 22)
                    }
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background { PaperBackdrop() }
        .foregroundStyle(AppTheme.ink)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $milestoneSheet) { destination in
            switch destination {
            case .celebration(let milestone):
                MilestoneDetailView(milestone: milestone)
            case .upcoming(let milestone):
                UpcomingMilestoneView(milestone: milestone)
            }
        }
        .onAppear { replay() }
        .onChange(of: replayToken) { _, _ in replay() }
        .onChange(of: scenePhase) { previous, current in
            guard previous != .active, current == .active else { return }
            replay()
        }
        .onChange(of: milestoneSheet?.id) { previous, current in
            guard previous != nil, current == nil else { return }
            replay()
        }
        .onDisappear { dropTask?.cancel() }
    }

    private var topBar: some View {
        GlassControlGroup {
            HStack {
                BrandWordmark()
                Spacer()
                Button(action: editAction) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 44, height: 44)
                }
                .modifier(GlassActionStyle())
                .accessibilityLabel("기념일 수정")
                .accessibilityIdentifier("edit-anniversary-button")
            }
        }
        .padding(.horizontal, AppTheme.horizontalPadding)
        .padding(.top, 8)
    }

    private var introduction: some View {
        VStack(spacing: 8) {
            Text(anniversary.title)
                .font(.system(.title, design: .serif).weight(.medium))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(anniversary.startDate.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits)))부터")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 6)
    }

    private func jarExhibit(height: CGFloat) -> some View {
        Button(action: replay) {
            PhotographicJarScene(progress: progress, replayID: replayID, reduceMotion: reduceMotion)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("유리병 속 도토리")
        .accessibilityValue("함께한 날 \(progress.acornsInCurrentJar)일" +
            (isDropping ? ", 도토리 떨어지는 중" : ""))
        .accessibilityHint("탭하면 오늘의 도토리가 병 입구로 떨어집니다")
        .accessibilityIdentifier("acorn-jar")
    }

    private var replayButton: some View {
        GlassControlGroup {
            Button(action: replay) {
                Label("한 번 더 담아보기", systemImage: "arrow.clockwise")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 7)
            }
            .modifier(GlassSecondaryActionStyle())
            .buttonBorderShape(.capsule)
            .disabled(progress.isWaitingToStart || progress.acornsInCurrentJar == 0)
            .accessibilityIdentifier("replay-acorn-button")
        }
    }

    private var daySummary: some View {
        VStack(spacing: 7) {
            Text(progress.counterText)
                .font(.system(size: counterSize, weight: .light, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .accessibilityIdentifier("day-counter")
            if progress.isWaitingToStart {
                Text("첫 도토리까지 \(abs(progress.elapsedDays))일")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            } else {
                Text("\(progress.completedJars + 1)번째 병 · \(progress.acornsInCurrentJar) / \(progress.currentJarCapacity)일")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                ProgressView(value: Double(progress.acornsInCurrentJar),
                             total: Double(progress.currentJarCapacity))
                    .tint(AppTheme.accent.opacity(0.65))
                    .frame(width: 100)
                    .scaleEffect(y: 0.6)
                    .accessibilityLabel("현재 병에 담긴 시간")
            }
        }
    }

    private var milestoneCard: some View {
        Button {
            if let milestone = progress.todayMilestone {
                milestoneSheet = .celebration(milestone)
            } else {
                milestoneSheet = .upcoming(progress.nextMilestone)
            }
        } label: {
            HStack(spacing: 12) {
                Image("GoldenAcornSprite")
                    .resizable().scaledToFit().frame(width: 39, height: 44)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    EditorialEyebrow(title: progress.todayMilestone == nil ? "다음 황금도토리" : "특별한 오늘")
                    Text(progress.todayMilestone.map { "오늘은 \($0.title)" } ?? progress.nextMilestone.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                }
                Spacer(minLength: 4)
                if progress.todayMilestone == nil {
                    Text("\(progress.nextMilestone.daysRemaining)일 후")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .modifier(PaperSurface())
            .contentShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(progress.todayMilestone.map { "황금도토리 \($0.title)" }
            ?? "다음 황금도토리 \(progress.nextMilestone.title), \(progress.nextMilestone.daysRemaining)일 후")
        .accessibilityIdentifier(progress.todayMilestone == nil ? "next-milestone-button" : "milestone-celebration")
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

private enum MilestoneSheet: Identifiable {
    case celebration(AnniversaryMilestone)
    case upcoming(AnniversaryProgress.Milestone)

    var id: String {
        switch self {
        case .celebration(let milestone): "celebration-\(milestone.id)"
        case .upcoming(let milestone): "upcoming-\(milestone.date.timeIntervalSince1970)"
        }
    }
}
