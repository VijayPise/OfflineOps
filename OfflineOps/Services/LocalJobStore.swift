import Foundation

// MARK: - Local Store

protocol LocalStoring {
    func loadJobs() -> [Job]
    func saveJobs(_ jobs: [Job])
}

final class LocalJobStore: LocalStoring {

    private let fileURL: URL

    init(filename: String = "jobs.json") {
        let docs = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        )[0]
        self.fileURL = docs.appendingPathComponent(filename)
    }

    func loadJobs() -> [Job] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Job].self, from: data)) ?? []
    }

    func saveJobs(_ jobs: [Job]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(jobs) else { return }

        try? data.write(to: fileURL, options: .atomic)
    }
}
