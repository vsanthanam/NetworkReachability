# ``NetworkReachability``

A Swift replacement for `SCNetworkReachability` with support for structured concurrency.

NetworkReachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). Because these APIs were originally written in C, they are old and cumbersome to use from Swift. NetworkReachability wraps these APIs in Swift and provides a modern interface for the most common use cases.

NetworkReachability supports with the following Apple platform releases:

* iOS 13.0 - 15.x
* macOS 10.15 - 13.x
* tvOS 13.0 - 15.x
* watchOS 13.0 - 15.x

## Usage

Basic usage of NetworkReachability is the same regardless of your observability mechanism. Initialize an instance of ``NetworkMonitor`` and retain it in memory. From there, you can observe changes using one of the mechanisms described below.

### Synchronously

```swift
import NetworkReachability

final class MyObject {

    func checkReachability() {
        do {
            let monitor = try NetworkMonitor()
            let reachability = try monitor.currentReachability
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
                for try await reachability in monitor.reachability {
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
    
    func monitor(_ monitor: NetworkMonitor, didUpdateReachability reachability: Reachability) {
        switch reachability {
            // do something
        }
    }
    
    func monitor(_ monitor: NetworkMonitor, didFailWithError error: Error) {
        // handle error
    }
}
```

### Combine

```swift
import Combine
import NetworkReachability

final class MyObject {

    var monitor: NetworkMonitor?
    var cancellable: AnyCancellable?
    
    func startObserving() throws {
        monitor = try NetworkMonitor()
        cancellable = monitor?.reachabilityPublisher
            .sink { completion in
                    // handle completion
                } receiveValue: { reachability in 
                    switch reachability {
                        // do something
                    }
                }
    }
    
    func stopObserving() {
        cancellable?.stop()
        cancellable = nil
        monitor = nil
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
            let reachability = try monitor.currentReachability
            switch reachability {
                // do something
            }
        } catch {
            // handle error
        }
    }
}
```
