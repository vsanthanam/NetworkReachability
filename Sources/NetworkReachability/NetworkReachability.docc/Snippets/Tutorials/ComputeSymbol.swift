import SwiftUI

struct ContentView: View {

    @ObservedObject
    var reachabilityManager: ReachabilityManager

    var body: some View {
        Text("Hello, world!")
            .padding()
    }

    private var symbolName: String {
        switch reachabilityManager.reachability {
        case .wifi:
            "wifi.circle.fill"
        case .ethernet:
            "cable.connector"
        case .unknown:
            "questionmark.circle.fill"
        case .cellular:
            "antenna.radiowaves.left.and.right.circle.fill"
        case .disconnected:
            "xmark.circle.fill"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(reachabilityManager: .init())
    }
}
