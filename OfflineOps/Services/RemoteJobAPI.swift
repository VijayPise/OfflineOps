import Foundation

// MARK: - Remote API Errors
enum RemoteAPIError: Error, LocalizedError {
    case offline
    case serverError
    case conflict(serverJob: Job)

    var errorDescription: String? {
        switch self {
        case .offline:      return "No internet connection."
        case .serverError:  return "Server error — will retry."
        case .conflict:     return "This job was changed elsewhere."
        }
    }
}

// MARK: - Remote API Protocol

protocol RemoteJobAPI {
    func push(_ job: Job) async throws -> Job
    func delete(_ jobID: UUID) async throws
    func fetchAll() async throws -> [Job]
}

// MARK: - Mock Remote API
final class MockRemoteJobAPI: RemoteJobAPI {

    private var serverJobs: [UUID: Job] = [:]
    private let simulatedLatency: UInt64 = 600_000_000

    func push(_ job: Job) async throws -> Job {
        try await Task.sleep(nanoseconds: simulatedLatency)

        if Double.random(in: 0...1) < 0.1 {
            throw RemoteAPIError.serverError
        }

        if let existing = serverJobs[job.id],
           let serverVersion = existing.serverUpdatedAt,
           let localBaseline = job.serverUpdatedAt,
           serverVersion > localBaseline {
            throw RemoteAPIError.conflict(serverJob: existing)
        }

        var confirmed = job
        confirmed.syncStatus = .synced
        confirmed.serverUpdatedAt = Date()
        serverJobs[job.id] = confirmed
        return confirmed
    }

    func delete(_ jobID: UUID) async throws {
        try await Task.sleep(nanoseconds: simulatedLatency)
        serverJobs.removeValue(forKey: jobID)
    }

    func fetchAll() async throws -> [Job] {
        try await Task.sleep(nanoseconds: simulatedLatency)
        return Array(serverJobs.values)
    }

    func simulateServerSideEdit(jobID: UUID, newTitle: String) {
        guard var job = serverJobs[jobID] else { return }
        job.title = newTitle
        job.serverUpdatedAt = Date()
        serverJobs[jobID] = job
    }
}
