import Foundation
import CoreLocation

// MARK: - Sync Status

enum SyncStatus: String, Codable {
    case synced
    case pendingCreate
    case pendingUpdate
    case pendingDelete
    case conflict
    case failed
}

// MARK: - Job Status
enum JobStatus: String, Codable, CaseIterable {
    case scheduled
    case enRoute
    case inProgress
    case completed
    case cancelled

    var label: String {
        switch self {
        case .scheduled:  return "Scheduled"
        case .enRoute:    return "En Route"
        case .inProgress: return "In Progress"
        case .completed:  return "Completed"
        case .cancelled:  return "Cancelled"
        }
    }
}

// MARK: - Job

struct Job: Identifiable, Codable {
    let id: UUID
    var title: String
    var customerName: String
    var address: String
    var latitude: Double
    var longitude: Double
    var scheduledDate: Date
    var status: JobStatus
    var notes: String
    var photoLocalPaths: [String]
    var completedAt: Date?

  
    var syncStatus: SyncStatus
    var localUpdatedAt: Date
    var serverUpdatedAt: Date?
    var version: Int                   

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        id: UUID = UUID(),
        title: String,
        customerName: String,
        address: String,
        latitude: Double,
        longitude: Double,
        scheduledDate: Date,
        status: JobStatus = .scheduled,
        notes: String = "",
        photoLocalPaths: [String] = [],
        completedAt: Date? = nil,
        syncStatus: SyncStatus = .pendingCreate,
        localUpdatedAt: Date = Date(),
        serverUpdatedAt: Date? = nil,
        version: Int = 1
    ) {
        self.id = id
        self.title = title
        self.customerName = customerName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.scheduledDate = scheduledDate
        self.status = status
        self.notes = notes
        self.photoLocalPaths = photoLocalPaths
        self.completedAt = completedAt
        self.syncStatus = syncStatus
        self.localUpdatedAt = localUpdatedAt
        self.serverUpdatedAt = serverUpdatedAt
        self.version = version
    }
}

// MARK: - Sample Data (for previews & first-run demo)
extension Job {
    static let sample = Job(
        title: "AC Unit Repair",
        customerName: "Anita Desai",
        address: "221 Baker Street, Pune",
        latitude: 18.5204,
        longitude: 73.8567,
        scheduledDate: Date(),
        status: .scheduled,
        syncStatus: .synced
    )

    static let sampleList: [Job] = [
        Job(title: "AC Unit Repair", customerName: "Anita Desai",
            address: "221 Baker Street, Pune", latitude: 18.5204, longitude: 73.8567,
            scheduledDate: Date(), status: .scheduled, syncStatus: .synced),
        Job(title: "Termite Inspection", customerName: "Rohan Mehta",
            address: "45 MG Road, Pune", latitude: 18.5314, longitude: 73.8446,
            scheduledDate: Date().addingTimeInterval(3600), status: .enRoute, syncStatus: .pendingUpdate),
        Job(title: "Lawn Treatment", customerName: "Sara Khan",
            address: "12 Camp Street, Pune", latitude: 18.5089, longitude: 73.8553,
            scheduledDate: Date().addingTimeInterval(7200), status: .inProgress, syncStatus: .pendingCreate),
        Job(title: "HVAC Maintenance", customerName: "Vikram Patil",
            address: "78 FC Road, Pune", latitude: 18.5246, longitude: 73.8398,
            scheduledDate: Date().addingTimeInterval(-3600), status: .completed,
            completedAt: Date(), syncStatus: .failed),
    ]
}
