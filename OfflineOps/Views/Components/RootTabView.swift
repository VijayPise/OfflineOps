import SwiftUI

// MARK: - Root Tab View
struct RootTabView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var syncEngine: SyncEngine

    init() {
        let monitor = NetworkMonitor()
        _networkMonitor = StateObject(wrappedValue: monitor)
        _syncEngine = StateObject(wrappedValue: SyncEngine(networkMonitor: monitor))
    }

    var body: some View {
        TabView {
            JobListView(
                viewModel: JobListViewModel(syncEngine: syncEngine, networkMonitor: networkMonitor)
            )
            .tabItem {
                Label("Jobs", systemImage: "list.bullet.clipboard.fill")
            }

            MapOverviewView(syncEngine: syncEngine)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
        }
        .tint(FTTheme.primary)
    }
}

#Preview {
    RootTabView()
}
