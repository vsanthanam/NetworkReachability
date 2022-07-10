import SwiftUI

struct ContentView: View {

    @ObservedObject
    var reachabilityManager: ReachabilityManager

    var body: some View {
        Image(systemName: symbolName)
    }

    private var symbolName: String {
        switch reachabilityManager.reachability {
        case .wifi:
            return "wifi.circle.fill"
        case .ethernet:
            return "cable.connector"
        case .unknown:
            return "questionmark.circle.fill"
        case .cellular:
            return "antenna.radiowaves.left.and.right.circle.fill"
        case .disconnected:
            return "xmark.circle.fill"
        }
    }

    private var backgroundColor: Color {
        switch reachabilityManager.reachability {
        case .disconnected:
            return .red
        case .unknown:
            return .yellow
        case .wifi, .ethernet, .cellular:
            return .green
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(reachabilityManager: .init())
    }
}
