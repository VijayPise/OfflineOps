import Foundation
import Combine

// MARK: - Job List ViewModel

@MainActor
final class JobListViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var statusFilter: JobStatus?

    let syncEngine: SyncEngine
    let networkMonitor: NetworkMonitor

    init(syncEngine: SyncEngine, networkMonitor: NetworkMonitor) {
        self.syncEngine = syncEngine
        self.networkMonitor = networkMonitor
    }

    var filteredJobs: [Job] {
        syncEngine.jobs
            .filter { job in
                statusFilter == nil || job.status == statusFilter
            }
            .filter { job in
                searchText.isEmpty
                    || job.title.localizedCaseInsensitiveContains(searchText)
                    || job.customerName.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    var todayJobs: [Job] {
        filteredJobs.filter { Calendar.current.isDateInToday($0.scheduledDate) }
    }

    func refresh() async {
        await syncEngine.manualSync()
    }
}
