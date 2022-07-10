import Combine
import Network
import NetworkReachability

final class ReachabilityManager: ObservableObject {

    init() {
        setUp()
    }

    enum Status {
        case ethernet
        case wifi
        case cellular
        case unknown
        case disconnected
    }

    @Published
    var reachability: Status = .disconnected

    private var monitor: NetworkMonitor!

    private func setUp() {
        monitor = .init() { [weak self] _, networkPath in
            guard let self = self else { return }
            if networkPath.usesInterfaceType(.wiredEthernet) {
                self.reachability = .ethernet
            } else if networkPath.usesInterfaceType(.wifi) {
                self.reachability = .wifi
            } else if networkPath.usesInterfaceType(.cellular) {
                self.reachability = .cellular
            } else if networkPath.status == .satisfied {
                self.reachability = .unknown
            } else {
                self.reachability = .disconnected
            }
        }
    }
}
