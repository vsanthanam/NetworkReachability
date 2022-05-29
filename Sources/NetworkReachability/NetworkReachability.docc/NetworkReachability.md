# ``NetworkReachability``

A Swift replacement for `SCNetworkReachability` with support for structured concurrency.

NetworkReachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). Because these APIs were originally written in C, they are old and cumbersome to use from Swift. NetworkReachability wraps these APIs in Swift and provides a modern interface for the most common use cases.

NetworkReachability supports with the following Apple platform releases:

* iOS 13.0 - 15.x
* macOS 10.15 - 13.x
* tvOS 13.0 - 15.x
* watchOS 13.0 - 15.x

## Usage

To determine the current reachability status. Initialize an instance of ``NetworkMonitor`` and access `reachability` property. You can also pass in an optional delegate or update handler to recieve reachability status updates on the main thread. ``NetworkMonitor`` instances also fire notifications through `NotificationCenter.default`. See the examples these patterns and more below.

## Examples

### Synchronously

```swift
import NetworkReachability

final class MyObject {

    func checkReachability() {
        do {
            let monitor = try NetworkMonitor()
            let reachability = try monitor.reachability
            switch reachability {
                // do something
            }
        } catch {
            // handle error
        }
    }
}
```

### Asynchronously

```swift
import NetworkReachability

final class MyObject {

    func startObserving() {
        reachabilityTask = observeReachability()
    }
    
    func stopObserving() {
        reachabilityTask?.cancel()
        reachabilityTask = nil
    }

    var reachabilityTask: Task<Void, Error>?

    func observeReachability() -> Task<Void, Error> {
        Task {
            do {
                let monitor = try NetworkMonitor()
                for try await reachability in NetworkMonitor.reachability {
                    switch reachability {
                        // do something
                    }
                }
            } catch {
                // handle error
            }
        }
    }
}

```

### Closures

```swift
import NetworkReachability

final class MyObject {
    
    var monitor: NetworkMonitor?
    
    func startObserving() throws {
        monitor = try NetworkMonitor() { (monitor: NetworkMonitor, result: NetworkMonitor.Result) in
            do {
                let reachability = try result.get()
                switch reachability {
                    // do something
                }
            } catch {
                // handle error
            }
        }
    }
    
    func stopObserving() {
        monitor = nil
    }
}
```

### Delegation

```swift
import NetworkReachability

final class MyObject: NetworkMonitorDelegate {

    var monitor: NetworkMonitor?
    
    func startObserving() throws {
        monitor = try NetworkMonitor(delegate: self)
    }
    
    func stopObserving() {
        monitor = nil
    }
    
    func networkMonitor(_ monitor: NetworkMonitor, didUpdateReachability reachability: Reachability) {
        switch reachability {
            // do something
        }
    }
    
    func networkMonitor(_ monitor: NetworkMonitor, didFailWithError error: Error) {
        // handle error
    }
}
```

### Combine

```swift
import Combine
import NetworkReachability

final class MyObject {

    var cancellable: AnyCancellable?
    
    func startObserving() throws {
        cancellable = NetworkMonitor.reachabilityPublisher
            .sink { completion in
                    // handle completion
                } receiveValue: { reachability in 
                    switch reachability {
                        // do something
                    }
                }
    }
    
    func stopObserving() {
        cancellable?.cancel()
        cancellable = nil
    }
}
```

### NotificationCenter

```swift
import NetworkMonitor

final class MyObject {

    var monitor: NetworkMonitor?
    var cancellable: AnyCancellable?
    
    func startObserving() throws {
        monitor = try NetworkMonitor(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReachability:), name: .reachabilityChanged)
    }
    
    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged)
    }
    
    @objc
    func handleReachability(_ notification: Notification) {
        guard let monitor = notification.object as? NetworkMonitor else { return }
        do {
            let reachability = try monitor.reachability
            switch reachability {
                // do something
            }
        } catch {
            // handle error
        }
    }
}
```
