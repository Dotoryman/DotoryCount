import SwiftData
import SwiftUI
import OSLog

struct AnniversaryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let anniversary: Anniversary?
    private let logger = Logger(subsystem: "com.dotoryman.dotorycount", category: "AnniversaryEditor")
    private let maximumTitleLength = 30

    @State private var title: String
    @State private var startDate: Date
    @State private var dateSheet: DateSheetDestination?
    @State private var presentedAlert: EditorAlert?
    @FocusState private var isTitleFocused: Bool

    init(anniversary: Anniversary? = nil) {
        self.anniversary = anniversary
        _title = State(initialValue: anniversary?.title ?? "")
        _startDate = State(initialValue: anniversary?.startDate ?? .now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image("AcornSprite").resizable().scaledToFit()
                            .frame(width: 44, height: 44).accessibilityHidden(true)
                        Text(anniversary == nil ? "어떤 날을 기억할까요?" : "우리의 시간을 다듬어요")
                            .font(.system(.title2, design: .serif).weight(.medium))
                        Text("이름과 시작한 날만 정하면 준비가 끝나요.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        EditorialEyebrow(title: "기념일 이름")
                        TextField("이름", text: $title, prompt: Text("우리의 시작"))
                            .font(.title3.weight(.medium))
                            .textInputAutocapitalization(.sentences)
                            .submitLabel(.done)
                            .focused($isTitleFocused)
                            .onSubmit { isTitleFocused = false }
                            .accessibilityIdentifier("anniversary-title-field")
                        HStack {
                            Text("짧고 소중한 이름을 붙여주세요.")
                            Spacer()
                            Text("\(title.count)/\(maximumTitleLength)")
                                .monospacedDigit()
                                .foregroundStyle(title.count > maximumTitleLength ? .red : AppTheme.secondaryText)
                        }
                        .font(.caption2)
                        .foregroundStyle(AppTheme.secondaryText)
                    }
                    .padding(20)
                    .modifier(PaperSurface())

                    Button {
                        isTitleFocused = false
                        dateSheet = .choose
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundStyle(AppTheme.accent)
                            VStack(alignment: .leading, spacing: 6) {
                                EditorialEyebrow(title: "처음 시작한 날")
                                Text(startDate.formatted(date: .long, time: .omitted))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppTheme.ink)
                            }
                            Spacer(minLength: 4)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .padding(20)
                        .frame(minHeight: 90)
                        .modifier(PaperSurface())
                        .contentShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("anniversary-date-picker")

                    draftPreview

                    if anniversary != nil {
                        Button("기념일 삭제", role: .destructive) {
                            presentedAlert = .deleteConfirmation
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .accessibilityIdentifier("delete-anniversary-button")
                        .accessibilityHint("저장된 기념일을 삭제하기 전에 확인합니다")
                    }
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.bottom, 30)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background { PaperBackdrop() }
            .foregroundStyle(AppTheme.ink)
            .navigationTitle(anniversary == nil ? "기념일 만들기" : "기념일 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: save)
                        .disabled(!isTitleValid)
                        .accessibilityIdentifier("save-anniversary-button")
                }
            }
            .sheet(item: $dateSheet) { _ in
                StartDateSelectionSheet(date: $startDate)
            }
            .alert(item: $presentedAlert) { alert in
                switch alert {
                case .deleteConfirmation:
                    return Alert(
                        title: Text("기념일을 삭제할까요?"),
                        message: Text("쌓인 도토리 기록도 함께 사라집니다."),
                        primaryButton: .destructive(Text("삭제"), action: deleteAnniversary),
                        secondaryButton: .cancel()
                    )
                case .persistenceFailure:
                    return Alert(
                        title: Text("변경사항을 저장할 수 없어요"),
                        message: Text("잠시 후 다시 시도해 주세요."),
                        dismissButton: .default(Text("확인"))
                    )
                }
            }
        }
    }

    private var draftPreview: some View {
        let progress = AnniversaryCalculator.progress(from: startDate)
        return HStack(spacing: 18) {
            JarArtworkView(progress: progress, viewport: .widget)
                .frame(width: 74, height: 94)
            VStack(alignment: .leading, spacing: 6) {
                EditorialEyebrow(title: "이 병에 담길 시간")
                Text(progress.counterText)
                    .font(.system(.title2, design: .rounded).weight(.medium))
                    .monospacedDigit()
                Text(progress.isWaitingToStart
                     ? "시작일까지 \(abs(progress.elapsedDays))일 남았어요."
                     : "하루마다 하나씩, \(progress.completedJars + 1)번째 병에 담겨요.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isTitleValid: Bool {
        !trimmedTitle.isEmpty && title.count <= maximumTitleLength
    }

    private func save() {
        do {
            let savedAnniversary: Anniversary
            if let anniversary {
                anniversary.title = trimmedTitle
                anniversary.startDate = startDate
                savedAnniversary = anniversary
            } else {
                let newAnniversary = Anniversary(title: trimmedTitle, startDate: startDate)
                modelContext.insert(newAnniversary)
                savedAnniversary = newAnniversary
            }

            try modelContext.save()
            WidgetSnapshotStore.publish(savedAnniversary)
            dismiss()
        } catch {
            modelContext.rollback()
            logger.error("Failed to save anniversary: \(error.localizedDescription, privacy: .public)")
            presentedAlert = .persistenceFailure
        }
    }

    private func deleteAnniversary() {
        guard let anniversary else { return }

        do {
            modelContext.delete(anniversary)
            try modelContext.save()
            WidgetSnapshotStore.publish(nil)
            dismiss()
        } catch {
            modelContext.rollback()
            logger.error("Failed to delete anniversary: \(error.localizedDescription, privacy: .public)")
            presentedAlert = .persistenceFailure
        }
    }
}

private enum DateSheetDestination: Identifiable {
    case choose

    var id: String { "choose-date" }
}

private enum EditorAlert: Identifiable {
    case deleteConfirmation
    case persistenceFailure

    var id: String {
        switch self {
        case .deleteConfirmation:
            return "delete-confirmation"
        case .persistenceFailure:
            return "persistence-failure"
        }
    }
}
