import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \Anniversary.createdAt) private var anniversaries: [Anniversary]
    @State private var presentedSheet: AnniversarySheet?

    var body: some View {
        Group {
            if let anniversary = anniversaries.first {
                AnniversaryDashboard(anniversary: anniversary) {
                    presentedSheet = .edit(anniversary)
                }
            } else {
                EmptyAnniversaryView {
                    presentedSheet = .create
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .sheet(item: $presentedSheet) { destination in
            switch destination {
            case .create:
                AnniversaryEditorView()
            case .edit(let anniversary):
                AnniversaryEditorView(anniversary: anniversary)
            }
        }
    }
}

private enum AnniversarySheet: Identifiable {
    case create
    case edit(Anniversary)

    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let anniversary):
            return "edit-\(anniversary.id.uuidString)"
        }
    }
}

private struct EmptyAnniversaryView: View {
    let createAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.surface)
                    .frame(width: 150, height: 150)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 58, weight: .light))
                    .foregroundStyle(AppTheme.accent)
                    .accessibilityHidden(true)
            }

            VStack(spacing: 8) {
                Text("소중한 날을 담아보세요")
                    .font(.title2.bold())
                Text("하루마다 유리병에 도토리 하나가 쌓여요.")
                    .font(.body)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button(action: createAction) {
                Label("기념일 만들기", systemImage: "plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            .accessibilityIdentifier("create-anniversary-button")

            Spacer()
        }
        .padding(.horizontal, AppTheme.horizontalPadding)
        .navigationTitle("DotoryCount")
    }
}

private struct AnniversaryDashboard: View {
    let anniversary: Anniversary
    let editAction: () -> Void

    @State private var latestAcornPresentation: LatestAcornPresentation = .hidden
    @State private var selectedMilestone: AnniversaryMilestone?

    private var progress: AnniversaryProgress {
        AnniversaryCalculator.progress(from: anniversary.startDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 6) {
                    Text(anniversary.title)
                        .font(.title3.weight(.semibold))
                    Text(progress.counterText)
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .accessibilityIdentifier("day-counter")
                    Text(anniversary.startDate.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.top, 12)

                if let milestone = progress.todayMilestone {
                    celebrationBanner(milestone)
                }

                jarCard
                milestoneCard
            }
            .padding(.horizontal, AppTheme.horizontalPadding)
            .padding(.bottom, 28)
        }
        .navigationTitle("나의 도토리")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("수정", systemImage: "slider.horizontal.3", action: editAction)
                    .accessibilityIdentifier("edit-anniversary-button")
            }
        }
        .sheet(item: $selectedMilestone) { milestone in
            MilestoneDetailView(milestone: milestone)
        }
    }

    private var jarCard: some View {
        VStack(spacing: 16) {
            AcornJarView(
                acornCount: progress.acornsInCurrentJar,
                capacity: progress.currentJarCapacity,
                milestones: progress.jarMilestones,
                latestAcornPresentation: latestAcornPresentation,
                celebratingMilestone: progress.todayMilestone,
                onMilestoneTapped: { selectedMilestone = $0 }
            )
            .frame(width: 250, height: 320)

            if progress.isWaitingToStart {
                Text("시작일까지 \(abs(progress.elapsedDays))일 남았어요")
                    .font(.headline)
            } else {
                VStack(spacing: 5) {
                    Text("이번 병에 담긴 시간 \(progress.acornsInCurrentJar)일")
                        .font(.headline)
                    Text("\(jarFillPercentage)% 채움 · 완성한 병 \(progress.completedJars)개")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .task(id: progress.elapsedDays) {
            await prepareDailyAcornAnimation()
        }
    }

    private var jarFillPercentage: Int {
        guard progress.currentJarCapacity > 0 else { return 0 }
        return min(
            Int((Double(progress.acornsInCurrentJar) / Double(progress.currentJarCapacity) * 100).rounded()),
            100
        )
    }

    private func celebrationBanner(_ milestone: AnniversaryMilestone) -> some View {
        HStack(spacing: 13) {
            Image("GoldenAcornSprite")
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 52)
                .shadow(color: Color.yellow.opacity(0.34), radius: 8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("오늘은 \(milestone.title)")
                    .font(.headline)
                Text("황금도토리가 반짝이는 특별한 날이에요.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.22), AppTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.yellow.opacity(0.30), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("milestone-celebration")
    }

    private var milestoneCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "calendar.badge.clock")
                .font(.title2)
                .foregroundStyle(AppTheme.accent)

            VStack(alignment: .leading, spacing: 3) {
                Text("다음 기념일")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                Text(progress.nextMilestone.title)
                    .font(.headline)
                Text(progress.nextMilestone.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            Text("\(progress.nextMilestone.daysRemaining)일")
                .font(.headline.monospacedDigit())
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }

    @MainActor
    private func prepareDailyAcornAnimation() async {
        guard progress.elapsedDays > 0, progress.acornsInCurrentJar > 0 else {
            latestAcornPresentation = .static
            return
        }

        guard AcornJarLayout.addsVisualAcorn(onDay: progress.acornsInCurrentJar) else {
            latestAcornPresentation = .static
            return
        }

        let defaultsKey = "lastAnimatedElapsedDay.\(anniversary.id.uuidString)"
        let lastAnimatedDay = UserDefaults.standard.object(forKey: defaultsKey) as? Int
        let forcesAnimation = ProcessInfo.processInfo.arguments.contains("--replay-acorn-animation")

        guard forcesAnimation || lastAnimatedDay != progress.elapsedDays else {
            latestAcornPresentation = .static
            return
        }

        try? await Task.sleep(for: .milliseconds(450))
        guard !Task.isCancelled else { return }

        if !forcesAnimation {
            UserDefaults.standard.set(progress.elapsedDays, forKey: defaultsKey)
        }
        latestAcornPresentation = .falling

        try? await Task.sleep(for: .seconds(1.2))
        latestAcornPresentation = .static
    }
}

private struct MilestoneDetailView: View {
    let milestone: AnniversaryMilestone

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.16))
                    .frame(width: 170, height: 170)
                    .blur(radius: 2)

                Image("GoldenAcornSprite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 138, height: 150)
                    .shadow(color: Color.yellow.opacity(0.34), radius: 16, y: 6)
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(milestone.title)
                    .font(.largeTitle.bold())
                Text(milestone.date.formatted(date: .long, time: .omitted))
                    .font(.headline)
                    .foregroundStyle(AppTheme.secondaryText)
                Text(milestone.detail)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            Spacer()

            Button("닫기") {
                dismiss()
            }
            .font(.headline)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            .frame(maxWidth: .infinity)
        }
        .padding(28)
        .background(AppTheme.background.ignoresSafeArea())
        .presentationDetents([.medium])
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("milestone-detail")
    }
}
