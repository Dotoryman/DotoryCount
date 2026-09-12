import SwiftUI
import SwiftData

struct AppView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .tint(AppTheme.accent)
    }
}

#Preview("Empty") {
    AppView()
        .modelContainer(PreviewContainer.empty)
}

#Preview("Anniversary") {
    AppView()
        .modelContainer(PreviewContainer.withSample)
}
