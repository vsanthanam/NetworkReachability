# ``Reachability``

A Swift replacement for SCNetworkReachability with support for structured concurrency.

Reachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). These APIs were originally written in C and are old, cumbersome to use, and do not play nicely with many modern Swift language patterns. Reachability wraps these APIs in Swift and provides a modern interface for the most common use cases.

Reachability supports with the following Apple platform releases:

* iOS 13.0 - 15.x
* macOS 10.15 - 13.x
* tvOS 13.0 - 15.x
* watchOS 13.0 - 15.x

Reachability supports synchronous reachability queries, as well as constant asynchronous reachability observation via the following mechanisms:

* Delegation
* Closures
* [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter)
* [Swift Structured Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
* [Combine](https://developer.apple.com/documentation/combine)

## Installation

Reachability is currently distributed exclusively through the [Swift Package Manager](https://www.swift.org/package-manager/). 

To add Reachability as a dependency to an existing Swift package, add the following line of code to the `packages` parameter of your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vsanthanam/Reachability.git", .upToNextMajor(from: "1.0.0"))
]
```

To add Reachability as a dependency to an Xcode Project: 

- Choose File -> Swift Packages -> Add Package Dependency...
- Enter package URL `https://github.com/vsanthanam/Reachability.git` and select your release and of choice.

Other distribution mechanisms like CocoaPods or Carthage may be added in the future.

## Usage

Basic usage of Reachability is the same regardless of your observability mechanism. Initialize an instance of ``ReachabilityMonitor`` and retain it in memory. From there, you can observe changes using one of the mechanisms described below.

### Synchronously

```swift
import Reachability

final class MyObject {

    func checkReachability() {
        do {
            let monitor = try ReachabilityMonitor()
            let status = try monitor.currentStatus
            switch status {
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
import Reachability

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
                let monitor = try ReachabilityMonitor()
                for try await status in monitor.status {
                    switch status {
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
import Reachability

final class MyObject {
    
    var monitor: ReachabilityMonitor?
    
    func startObserving() throws {
        monitor = try ReachabilityMonitor() { result in
            do {
                let status = try result.get()
                switch status {
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
import Reachability

final class MyObject: ReachabilityMonitorDelegate {

    var monitor: ReachabilityMonitor?
    
    func startObserving() throws {
        monitor = try ReachabilityMonitor(delegate: self)
    }
    
    func stopObserving() {
        monitor = nil
    }
    
    func monitor(_ monitor: ReachabilityMonitor, didUpdateStatus status: ReachabilityStatus) {
        switch status {
            // do something
        }
    }
    
    func monitor(_ monitor: ReachabilityMonitor, didFailWithError error: Error) {
        // handle error
    }
}
```

### Combine

```swift
import Combine
import Reachability

final class MyObject {

    var monitor: ReachabilityMonitor?
    var cancellable: AnyCancellable?
    
    func startObserving() throws {
        monitor = try ReachabilityMonitor()
        cancellable = monitor?.statusPublisher
            .sink { completion in
                    // handle completion
                } receiveValue: { status in 
                    switch status {
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
import ReachabilityMonitor

final class MyObject {

    var monitor: ReachabilityMonitor?
    var cancellable: AnyCancellable?
    
    func startObserving() throws {
        monitor = try ReachabilityMonitor(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChange:), name: .reachabilityStatusChanged)
    }
    
    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: .reachabilityStatusChanged)
    }
    
    @objc
    func handleChange(_ notification: Notification) {
        guard let monitor = notification.object as? ReachabilityMonitor else { return }
        do {
            let status = try monitor.currentStatus
            switch status {
                // do something
            }
        } catch {
            // handle error
        }
    }
}
```
