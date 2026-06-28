import SwiftUI

// MARK: - Design Tokens

enum FTTheme {

    
    static let primary      = Color(hex: "0B5FFF")
    static let primaryDark  = Color(hex: "073D9E")

    
    static let background   = Color(hex: "F4F6F9")
    static let surface      = Color.white
    static let surfaceDim   = Color(hex: "EAEDF2")

    
    static let textPrimary   = Color(hex: "10151C")
    static let textSecondary = Color(hex: "5B6573")

    
    static let statusScheduled  = Color(hex: "5B6573")
    static let statusEnRoute    = Color(hex: "0B84FF")
    static let statusInProgress = Color(hex: "FF9500")
    static let statusCompleted  = Color(hex: "1FAA59")
    static let statusCancelled  = Color(hex: "D64545")

    static let syncSynced   = Color(hex: "1FAA59")
    static let syncPending  = Color(hex: "FF9500")
    static let syncFailed   = Color(hex: "D64545")
    static let syncConflict = Color(hex: "8C3FD6")

    
    static let displayFont  = Font.system(size: 28, weight: .bold, design: .rounded)
    static let titleFont    = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont     = Font.system(size: 16, weight: .medium, design: .rounded)
    static let captionFont  = Font.system(size: 13, weight: .semibold, design: .rounded)

    
    static let cornerRadius: CGFloat = 16
    static let minTapTarget: CGFloat = 56
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}


extension JobStatus {
    var color: Color {
        switch self {
        case .scheduled:  return FTTheme.statusScheduled
        case .enRoute:    return FTTheme.statusEnRoute
        case .inProgress: return FTTheme.statusInProgress
        case .completed:  return FTTheme.statusCompleted
        case .cancelled:  return FTTheme.statusCancelled
        }
    }

    var icon: String {
        switch self {
        case .scheduled:  return "clock"
        case .enRoute:    return "car.fill"
        case .inProgress: return "wrench.and.screwdriver.fill"
        case .completed:  return "checkmark.circle.fill"
        case .cancelled:  return "xmark.circle.fill"
        }
    }
}

extension SyncStatus {
    var color: Color {
        switch self {
        case .synced:        return FTTheme.syncSynced
        case .pendingCreate, .pendingUpdate, .pendingDelete, .failed:
            return self == .failed ? FTTheme.syncFailed : FTTheme.syncPending
        case .conflict:       return FTTheme.syncConflict
        }
    }

    var icon: String {
        switch self {
        case .synced:        return "checkmark.icloud.fill"
        case .pendingCreate, .pendingUpdate, .pendingDelete:
            return "arrow.triangle.2.circlepath.icloud"
        case .failed:        return "exclamationmark.icloud.fill"
        case .conflict:      return "exclamationmark.triangle.fill"
        }
    }

    var label: String {
        switch self {
        case .synced:        return "Synced"
        case .pendingCreate: return "Waiting to upload"
        case .pendingUpdate: return "Waiting to upload"
        case .pendingDelete: return "Waiting to remove"
        case .failed:        return "Sync failed — retrying"
        case .conflict:      return "Needs your review"
        }
    }
}
