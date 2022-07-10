import Combine

final class ReachabilityManager: ObservableObject {

    enum Status {
        case ethernet
        case wifi
        case cellular
        case unknown
        case disconnected
    }

    @Published
    var reachability: Status = .disconnected

}
