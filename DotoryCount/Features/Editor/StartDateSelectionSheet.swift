import SwiftUI

enum StartDateInput {
    static func format(_ date: Date, calendar inputCalendar: Calendar = .autoupdatingCurrent) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = inputCalendar.timeZone
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d.%02d.%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    static func parse(_ text: String, calendar inputCalendar: Calendar = .autoupdatingCurrent) -> Date? {
        let groups = text.split(whereSeparator: { !$0.isNumber })
        let year: Int
        let month: Int
        let day: Int

        if groups.count == 1, groups[0].count == 8 {
            let digits = String(groups[0])
            year = Int(digits.prefix(4)) ?? 0
            month = Int(digits.dropFirst(4).prefix(2)) ?? 0
            day = Int(digits.suffix(2)) ?? 0
        } else if groups.count == 3 {
            year = Int(groups[0]) ?? 0
            month = Int(groups[1]) ?? 0
            day = Int(groups[2]) ?? 0
        } else {
            return nil
        }

        guard (1...9999).contains(year), (1...12).contains(month), (1...31).contains(day) else {
            return nil
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = inputCalendar.timeZone
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
            return nil
        }
        let checked = calendar.dateComponents([.year, .month, .day], from: date)
        guard checked.year == year, checked.month == month, checked.day == day else { return nil }
        return date
    }
}

private enum DateChoiceMode: String, CaseIterable {
    case calendar = "달력"
    case direct = "직접 입력"
}

struct StartDateSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var date: Date

    @State private var draftDate: Date
    @State private var dateText: String
    @State private var mode: DateChoiceMode = .calendar
    @FocusState private var isDateTextFocused: Bool

    init(date: Binding<Date>) {
        _date = date
        _draftDate = State(initialValue: date.wrappedValue)
        _dateText = State(initialValue: StartDateInput.format(date.wrappedValue))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("빠른 선택") {
                    HStack(spacing: 10) {
                        preset("오늘", daysAgo: 0)
                        preset("어제", daysAgo: 1)
                        preset("1년 전", yearsAgo: 1)
                    }
                    .modifier(GlassSecondaryActionStyle())
                    .listRowBackground(Color.clear)
                }

                Section {
                    Picker("선택 방법", selection: $mode) {
                        ForEach(DateChoiceMode.allCases, id: \.self) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)

                    if mode == .calendar {
                        DatePicker("기준일", selection: $draftDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .accessibilityIdentifier("anniversary-graphical-date-picker")
                    } else {
                        TextField("YYYY.MM.DD", text: $dateText)
                            .keyboardType(.numbersAndPunctuation)
                            .textContentType(.none)
                            .focused($isDateTextFocused)
                            .accessibilityIdentifier("anniversary-direct-date-field")
                        Text("예: 2020.09.24 또는 20200924")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.secondaryText)
                        if !dateText.isEmpty && StartDateInput.parse(dateText) == nil {
                            Text("실제 달력에 있는 날짜를 입력해 주세요.")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                } header: {
                    Text("날짜 선택")
                }

                Section {
                    Text("선택한 날짜 · \(selectedDate.map { StartDateInput.format($0) } ?? "확인 필요")")
                        .font(.subheadline.weight(.medium))
                        .monospacedDigit()
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("기준일 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("적용") { applyDate() }
                        .disabled(selectedDate == nil)
                        .accessibilityIdentifier("apply-anniversary-date-button")
                }
            }
            .onChange(of: draftDate) { _, newValue in
                if mode == .calendar { dateText = StartDateInput.format(newValue) }
            }
            .onChange(of: mode) { _, newValue in
                if newValue == .direct { isDateTextFocused = true }
                else { isDateTextFocused = false }
            }
        }
    }

    private var selectedDate: Date? {
        mode == .calendar ? draftDate : StartDateInput.parse(dateText)
    }

    private func preset(_ title: String, daysAgo: Int) -> some View {
        Button(title) { selectRelativeDate(days: -daysAgo, years: 0) }
            .frame(maxWidth: .infinity)
    }

    private func preset(_ title: String, yearsAgo: Int) -> some View {
        Button(title) { selectRelativeDate(days: 0, years: -yearsAgo) }
            .frame(maxWidth: .infinity)
    }

    private func selectRelativeDate(days: Int, years: Int) {
        let calendar = Calendar.autoupdatingCurrent
        let today = calendar.startOfDay(for: .now)
        let shifted = calendar.date(byAdding: .year, value: years, to: today) ?? today
        draftDate = calendar.date(byAdding: .day, value: days, to: shifted) ?? shifted
        dateText = StartDateInput.format(draftDate)
        isDateTextFocused = false
    }

    private func applyDate() {
        guard let selectedDate else { return }
        date = selectedDate
        dismiss()
    }
}
