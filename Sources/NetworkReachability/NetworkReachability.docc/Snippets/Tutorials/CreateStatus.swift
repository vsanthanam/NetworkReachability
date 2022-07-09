final class ReachabilityManager {

    enum Status {
        case ethernet
        case wifi
        case cellular
        case unknown
        case disconnected
    }

    var reachability: Status = .disconnected

}
