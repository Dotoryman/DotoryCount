import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \Anniversary.createdAt) private var anniversaries: [Anniversary]
    @State private var presentedSheet: AnniversarySheet?
    @State private var dashboardReplayToken = 0

    var body: some View {
        Group {
            if let anniversary = anniversaries.first {
                CinematicAnniversaryDashboard(
                    anniversary: anniversary,
                    replayToken: dashboardReplayToken
                ) {
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
        .onChange(of: presentedSheet?.id) { previousSheet, currentSheet in
            guard previousSheet != nil, currentSheet == nil else { return }
            dashboardReplayToken &+= 1
        }
        .onAppear { WidgetSnapshotStore.publish(anniversaries.first) }
        .onChange(of: anniversaries.count) { _, _ in
            WidgetSnapshotStore.publish(anniversaries.first)
        }
        .onChange(of: anniversaries.first?.startDate) { _, _ in
            WidgetSnapshotStore.publish(anniversaries.first)
        }
        .onChange(of: anniversaries.first?.title) { _, _ in
            WidgetSnapshotStore.publish(anniversaries.first)
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
