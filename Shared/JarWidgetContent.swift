import Foundation
import SwiftUI

struct JarWidgetContent: View {
    let progress: AnniversaryProgress
    var isConfigured = true

    private var counter: String {
        guard isConfigured else { return "D+000" }
        let days = progress.elapsedDays
        return String(format: days >= 0 ? "D+%03d" : "D-%03d", abs(days))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 5) {
                JarArtworkView(progress: progress, viewport: .widget)
                    .frame(maxWidth: .infinity)
                    .frame(height: max(geometry.size.height - (isConfigured ? 35 : 48), 30))
                Text(counter)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if !isConfigured {
                    Text("기념일을 설정해 주세요")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 5)
            .frame(maxWidth: .infinity)
        }
    }
}
