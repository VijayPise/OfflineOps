import SwiftUI

// MARK: - Sync Status Badge

struct SyncStatusBadge: View {
    let status: SyncStatus
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.icon)
                .font(.system(size: compact ? 11 : 12, weight: .bold))
                .symbolEffect(.pulse, isActive: isPending)

            if !compact {
                Text(status.label)
                    .font(FTTheme.captionFont)
            }
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 5 : 6)
        .background(status.color.opacity(0.12))
        .clipShape(Capsule())
    }

    private var isPending: Bool {
        status == .pendingCreate || status == .pendingUpdate || status == .pendingDelete
    }
}

#Preview {
    VStack(spacing: 12) {
        SyncStatusBadge(status: .synced)
        SyncStatusBadge(status: .pendingUpdate)
        SyncStatusBadge(status: .failed)
        SyncStatusBadge(status: .conflict)
        SyncStatusBadge(status: .synced, compact: true)
    }
    .padding()
    .background(FTTheme.background)
}
