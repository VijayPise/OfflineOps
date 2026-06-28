import SwiftUI

// MARK: - Connectivity Banner

struct ConnectivityBanner: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    let pendingCount: Int
    let isSyncing: Bool

    var body: some View {
        if !networkMonitor.isConnected || pendingCount > 0 {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 13, weight: .bold))

                Text(message)
                    .font(FTTheme.captionFont)

                Spacer()

                if isSyncing {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.white)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(bannerColor)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private var iconName: String {
        if !networkMonitor.isConnected { return "wifi.slash" }
        return isSyncing ? "arrow.triangle.2.circlepath" : "icloud.and.arrow.up"
    }

    private var message: String {
        if !networkMonitor.isConnected {
            return pendingCount > 0
                ? "Offline — \(pendingCount) job\(pendingCount == 1 ? "" : "s") will sync automatically"
                : "Offline — your work is saved on this device"
        }
        return isSyncing
            ? "Syncing \(pendingCount) job\(pendingCount == 1 ? "" : "s")…"
            : "\(pendingCount) job\(pendingCount == 1 ? "" : "s") waiting to sync"
    }

    private var bannerColor: Color {
        !networkMonitor.isConnected ? FTTheme.textSecondary : FTTheme.statusInProgress
    }
}

#Preview {
    VStack(spacing: 0) {
        ConnectivityBanner(networkMonitor: NetworkMonitor(), pendingCount: 3, isSyncing: false)
    }
}
