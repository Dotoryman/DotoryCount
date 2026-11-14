import SwiftUI

struct MilestoneDetailView: View {
    let milestone: AnniversaryMilestone

    var body: some View {
        GoldenMilestonePresentation(eyebrow: "오늘의 황금도토리", title: milestone.title,
            date: milestone.date, message: milestone.detail)
            .accessibilityIdentifier("milestone-detail")
    }
}

struct UpcomingMilestoneView: View {
    let milestone: AnniversaryProgress.Milestone

    var body: some View {
        GoldenMilestonePresentation(eyebrow: "다음에 찾아올 특별한 날", title: milestone.title,
            date: milestone.date,
            message: "\(milestone.daysRemaining)일 뒤, 새로운 황금도토리가 병에 담겨요.")
    }
}

private struct GoldenMilestonePresentation: View {
    let eyebrow: String
    let title: String
    let date: Date
    let message: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ZStack {
                        Circle().fill(AppTheme.gold.opacity(0.10))
                            .frame(width: 156, height: 156)
                        Image("GoldenAcornSprite")
                            .resizable().scaledToFit().frame(width: 124, height: 124)
                            .shadow(color: AppTheme.gold.opacity(0.18), radius: 16, y: 7)
                    }
                    .accessibilityHidden(true)
                    EditorialEyebrow(title: eyebrow)
                    Text(title)
                        .font(.system(.largeTitle, design: .serif).weight(.medium))
                    Text(date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(message)
                        .font(.subheadline)
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .padding(.top, 3)
                }
                .padding(28)
                .frame(maxWidth: .infinity)
            }
            .background { PaperBackdrop() }
            .foregroundStyle(AppTheme.ink)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
