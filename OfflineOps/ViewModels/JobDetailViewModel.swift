import Foundation
import Combine

// MARK: - Job Detail ViewModel
@MainActor
final class JobDetailViewModel: ObservableObject {

    @Published var job: Job
    @Published var notesDraft: String
    @Published var showCompletionSheet = false

    private let syncEngine: SyncEngine

    init(job: Job, syncEngine: SyncEngine) {
        self.job = job
        self.notesDraft = job.notes
        self.syncEngine = syncEngine
    }

    func advanceStatus() {
        let next: JobStatus
        switch job.status {
        case .scheduled:  next = .enRoute
        case .enRoute:    next = .inProgress
        case .inProgress: next = .completed
        case .completed, .cancelled: return
        }

        if next == .completed {
            showCompletionSheet = true
            return
        }

        job.status = next
        syncEngine.updateJob(job)
    }

    func completeJob() {
        syncEngine.completeJob(job.id, notes: notesDraft)
        if let updated = syncEngine.jobs.first(where: { $0.id == job.id }) {
            job = updated
        }
        showCompletionSheet = false
    }

    func saveNotes() {
        job.notes = notesDraft
        syncEngine.updateJob(job)
    }
}
