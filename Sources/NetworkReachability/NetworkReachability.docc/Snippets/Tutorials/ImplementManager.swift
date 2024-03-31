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
            guard let self else { return }
            if networkPath.usesInterfaceType(.wiredEthernet) {
                reachability = .ethernet
            } else if networkPath.usesInterfaceType(.wifi) {
                reachability = .wifi
            } else if networkPath.usesInterfaceType(.cellular) {
                reachability = .cellular
            } else if networkPath.status == .satisfied {
                reachability = .unknown
            } else {
                reachability = .disconnected
            }
        }
    }
}
