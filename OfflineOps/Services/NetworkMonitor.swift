import Foundation
import Network
import Combine

// MARK: - Network Monitor

final class NetworkMonitor: ObservableObject {

    @Published private(set) var isConnected: Bool = true
    @Published private(set) var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi, cellular, ethernet, unknown
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.OfflineOps.networkmonitor")

    init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            let connected = path.status == .satisfied
            let type: ConnectionType = path.usesInterfaceType(.wifi)
                ? .wifi
                : path.usesInterfaceType(.cellular)
                    ? .cellular
                    : path.usesInterfaceType(.wiredEthernet)
                        ? .ethernet
                        : .unknown

            DispatchQueue.main.async {
                self.isConnected = connected
                self.connectionType = type
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
