import Foundation
import Combine

// MARK: - Sync Engine
@MainActor
final class SyncEngine: ObservableObject {

    @Published private(set) var jobs: [Job] = []
    @Published private(set) var isSyncing: Bool = false
    @Published private(set) var lastSyncedAt: Date?
    @Published private(set) var conflicts: [JobConflict] = []

    var pendingCount: Int {
        jobs.filter { $0.syncStatus != .synced }.count
    }

    private let localStore: LocalStoring
    private let remoteAPI: RemoteJobAPI
    private let networkMonitor: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    private var retryAttempts: [UUID: Int] = [:]

    init(
        localStore: LocalStoring = LocalJobStore(),
        remoteAPI: RemoteJobAPI = MockRemoteJobAPI(),
        networkMonitor: NetworkMonitor
    ) {
        self.localStore = localStore
        self.remoteAPI = remoteAPI
        self.networkMonitor = networkMonitor

        let loaded = localStore.loadJobs()
        self.jobs = loaded.isEmpty ? Job.sampleList : loaded
        persistLocally()

        observeConnectivity()
    }

    // MARK: - Connectivity-driven auto sync
    private func observeConnectivity() {
        networkMonitor.$isConnected
            .removeDuplicates()
            .sink { [weak self] connected in
                guard let self, connected else { return }
                Task { await self.syncPendingChanges() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Local-first mutations

    func createJob(_ job: Job) {
        var newJob = job
        newJob.syncStatus = .pendingCreate
        newJob.localUpdatedAt = Date()
        jobs.insert(newJob, at: 0)
        persistLocally()
        triggerSyncIfOnline()
    }

    func updateJob(_ job: Job) {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else { return }
        var updated = job
        updated.version += 1
        updated.localUpdatedAt = Date()
        updated.syncStatus = (jobs[index].syncStatus == .pendingCreate) ? .pendingCreate : .pendingUpdate
        jobs[index] = updated
        persistLocally()
        triggerSyncIfOnline()
    }

    func deleteJob(_ jobID: UUID) {
        guard let index = jobs.firstIndex(where: { $0.id == jobID }) else { return }
        
        if jobs[index].syncStatus == .pendingCreate {
            jobs.remove(at: index)
        } else {
            jobs[index].syncStatus = .pendingDelete
            jobs[index].localUpdatedAt = Date()
        }
        persistLocally()
        triggerSyncIfOnline()
    }

    func completeJob(_ jobID: UUID, notes: String) {
        guard let index = jobs.firstIndex(where: { $0.id == jobID }) else { return }
        jobs[index].status = .completed
        jobs[index].completedAt = Date()
        jobs[index].notes = notes
        updateJob(jobs[index])
    }

    // MARK: - Sync orchestration

    private func triggerSyncIfOnline() {
        guard networkMonitor.isConnected else { return }
        Task { await syncPendingChanges() }
    }

    func manualSync() async {
        await syncPendingChanges()
    }

    func syncPendingChanges() async {
        guard networkMonitor.isConnected, !isSyncing else { return }

        isSyncing = true
        defer { isSyncing = false }

        let pending = jobs.filter { $0.syncStatus == .pendingCreate
                                  || $0.syncStatus == .pendingUpdate
                                  || $0.syncStatus == .pendingDelete
                                  || $0.syncStatus == .failed }

        for job in pending {
            await syncSingle(job)
        }

        lastSyncedAt = Date()
        persistLocally()
    }

    private func syncSingle(_ job: Job) async {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else { return }

        do {
            if job.syncStatus == .pendingDelete {
                try await remoteAPI.delete(job.id)
                jobs.remove(at: index)
                retryAttempts[job.id] = nil
                return
            }

            let confirmed = try await remoteAPI.push(job)
            jobs[index] = confirmed
            retryAttempts[job.id] = nil

        } catch RemoteAPIError.conflict(let serverJob) {
            jobs[index].syncStatus = .conflict
            conflicts.append(JobConflict(localJob: job, serverJob: serverJob))

        } catch {
            let attempts = (retryAttempts[job.id] ?? 0) + 1
            retryAttempts[job.id] = attempts
            jobs[index].syncStatus = .failed
        }
    }

    // MARK: - Conflict resolution

    func resolveConflict(_ conflict: JobConflict, keepLocal: Bool) {
        guard let index = jobs.firstIndex(where: { $0.id == conflict.localJob.id }) else { return }

        if keepLocal {
            var job = conflict.localJob
            job.serverUpdatedAt = conflict.serverJob.serverUpdatedAt // adopt new baseline
            job.syncStatus = .pendingUpdate
            jobs[index] = job
        } else {
            jobs[index] = conflict.serverJob
        }

        conflicts.removeAll { $0.id == conflict.id }
        persistLocally()
        triggerSyncIfOnline()
    }

    // MARK: - Persistence
    private func persistLocally() {
        localStore.saveJobs(jobs)
    }
}

// MARK: - Job Conflict
struct JobConflict: Identifiable {
    let id = UUID()
    let localJob: Job
    let serverJob: Job
}
