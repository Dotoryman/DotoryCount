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
            Form {
                Section {
                    TextField("이름", text: $title, prompt: Text("우리의 시작"))
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.done)
                        .focused($isTitleFocused)
                        .accessibilityIdentifier("anniversary-title-field")

                    Button {
                        isTitleFocused = false
                        dateSheet = .choose
                    } label: {
                        HStack {
                            Text("기준일")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(startDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(AppTheme.secondaryText)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("anniversary-date-picker")
                } header: {
                    Text("기념일")
                } footer: {
                    HStack {
                        Text("이름은 30자까지 입력할 수 있어요.")
                        Spacer()
                        Text("\(title.count)/\(maximumTitleLength)")
                            .monospacedDigit()
                            .foregroundStyle(title.count > maximumTitleLength ? .red : AppTheme.secondaryText)
                    }
                }

                Section {
                    Text("입력한 날짜부터 하루마다 도토리가 하나씩 쌓입니다. 1주년마다 가득 찬 병을 보관하고 새 병을 시작해요.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                if anniversary != nil {
                    Section {
                        Button("기념일 삭제", role: .destructive) {
                            presentedAlert = .deleteConfirmation
                        }
                        .accessibilityIdentifier("delete-anniversary-button")
                        .accessibilityHint("저장된 기념일을 삭제하기 전에 확인합니다")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .scrollDismissesKeyboard(.interactively)
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
            .task {
                if anniversary == nil {
                    isTitleFocused = true
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
