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
    }

    private var jarCard: some View {
        VStack(spacing: 16) {
            AcornJarView(
                acornCount: progress.acornsInCurrentJar,
                capacity: progress.currentJarCapacity,
                latestAcornPresentation: latestAcornPresentation
            )
            .frame(width: 220, height: 280)

            if progress.isWaitingToStart {
                Text("시작일까지 \(abs(progress.elapsedDays))일 남았어요")
                    .font(.headline)
            } else {
                Text("가득 찬 병 \(progress.completedJars)개 · 새 병에 도토리 \(progress.acornsInCurrentJar)개")
                    .font(.headline)
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
