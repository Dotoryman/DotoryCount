import SwiftData
import SwiftUI

struct AnniversaryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let anniversary: Anniversary?
    @State private var title: String
    @State private var startDate: Date

    init(anniversary: Anniversary? = nil) {
        self.anniversary = anniversary
        _title = State(initialValue: anniversary?.title ?? "")
        _startDate = State(initialValue: anniversary?.startDate ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기념일") {
                    TextField("이름", text: $title, prompt: Text("우리의 시작"))
                        .textInputAutocapitalization(.sentences)
                        .accessibilityIdentifier("anniversary-title-field")

                    DatePicker("기준일", selection: $startDate, displayedComponents: .date)
                        .accessibilityIdentifier("anniversary-date-picker")
                }

                Section {
                    Text("입력한 날짜부터 하루마다 도토리가 하나씩 쌓입니다. 1주년마다 가득 찬 병을 보관하고 새 병을 시작해요.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle(anniversary == nil ? "기념일 만들기" : "기념일 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: save)
                        .disabled(trimmedTitle.isEmpty)
                        .accessibilityIdentifier("save-anniversary-button")
                }
            }
        }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        if let anniversary {
            anniversary.title = trimmedTitle
            anniversary.startDate = startDate
        } else {
            modelContext.insert(Anniversary(title: trimmedTitle, startDate: startDate))
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            assertionFailure("Failed to save anniversary: \(error)")
        }
    }
}
