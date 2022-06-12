# Reachability Monitor Programming Guide

Learn how to use Network Monitor APIs

## Overview

The easiest way use ``ReachabilityMonitor`` is to use its static `reachability` property

```swift
import NetworkReachability

do {
    let reachability = try ReachabilityMonitor.reachability
    // Do something with `reachability`
} catch {
    // Handle errors
}
```

Unlike ``NetworkMonitor``, ``ReachabilityMonitor``'s synchronous API is gauranteed to provide up-date-values. 

### Observing reachability updates.

If you need to observe all reachability changes, ``ReachabilityMonitor`` provides several asynchronous APIs that will allow you to integrate reachability data into any existing pipeline.

##### Closures

You can use a closure to observe reachability over time. You can pass in the closure on initialization, or add one later using the `updateHandler` property. The closure returns result types, which means they could contain errors instead of values.

```swift
import NetworkReachability

final class MyClass {

    var monitor: ReachabilityMonitor?

    func startMonitoring() {
        stopMonitoring()
        monitor = ReachabilityMonitor(updateHandler: { (monitor: ReachabilityMonitor, result: ReachabilityMonitor.Result) in
            do {
                let reachability = try result.get()
                // Do something with `monitor` or `reachability`
            } catch {
                // Handle error
            }
        }
    }

    func stopMonitoring() {
        monitor = nil
    }

}
```

- Important: ``ReachabilityMonitor`` always calls its update handler on the main thread.

##### Swift Concurrency

You can use an `AsyncSequence` to observe reachability updates over time using Swift Concurrency

```swift
import NetworkReachability

final class MyClass {
    
    var monitorTask: Task?

    func startObserving() {
        stopObserving()
        monitorTask = Task {
            do {
                for try await reachability in ReachabilityMonitor.reachabilityMonitorUpdates {
                    // Do something with `reachability`
                }
            } catch {
                // Handle error
            }
        }
    }

    func startObserving() {
        monitorTask?.cancel()
        monitorTask = nil
    }
}
```

- Note: This API requires iOS 13, macOS 10.15, tvOS 13, or watchOS 6

##### Delegation

You can use ``ReachabilityMonitorDelegate`` to recieve callbacks when the reachability changes. You can pass in a delegate object when the monitor is initialized, or you can assign one later.

```swift
import NetworkReachability

final class MyClass: ReachabilityMonitorDelegate {

    var monitor: ReachabilityMonitor?

    func startMonitoring() {
        stopMonitoring()
        monitor = ReachabilityMonitor(delegate: self)
    }

    func stopMonitoring() {
        monitor = nil
    }

    // MARK: - ReachabilityMonitorDelegate

    func reachabilityMonitor(_ monitor: ReachabilityMonitor, didUpdateReachability reachability: Reachability)
        // Do something with `reachability`
    }

    func reachabilityMonitor(_ monitor: ReachabilityMonitor, didFailWithError error: Error) {
        // Handle error
    }

}
```

- Important: ``ReachabilityMonitor`` always executes delegate calbacks on the main thread.

##### NotificationCenter

If you have retained an instance of ``ReachabilityMonitor`` in memory, but do not have access to it in the part of your code that needs reachability updates, you can 
observe reachability changes by observing notifications with the name `Notification.Name.reachabilityChanged` on the default notification center. The notification's `.object` property will contain the ``ReachabilityMonitor``. From there, you can use `currentReachability` property of the monitor, which you now know will be up-to-date thanks to the notification.

```swift
import Foundation
import NetworkReachability

final class MyClass {

    var monitor: ReachabilityMonitor?

    func startMonitoring() {
        stopMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdate:), name: .reachabilityhChanged)
        monitor = ReachabilityMonitor()
    }

    func stopMonitoring() {
        monitor = nil
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged)
    }

    @objc
    func handleUpdate(_ notification: Notification) {
        guard let monitor = notification.object as? ReachabilityMonitor else {
            return
        }
        do {
            let reachability = try monitor.currentReachability
        } catch {
            // Do something with `reachability`
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged)
    }

}
```

- Important: ``ReachabilityMonitor`` posts notifications on the main thread.

##### Combine

You can observe reachability changes using a [Combine](https://developer.apple.com/documentation/combine) with the `reachabilityPublisher` static property.

```swift
import Combine
import NetworkReachability

final class MyClass {
    
    var monitorCancellable: AnyCancellable?

    func startObserving() {
        stopObserving()
        monitorCancellable = ReachabilityMonitor.reachabilityPublisher
            .map(\.status.isReachable)
            .replaceError(with: false)
            .sink { isReachable in
                // Do something with `isReachable`
            }
    }

    func startObserving() {
        monitorCancellable?.cancel()
        monitorCancellable = nil
    }

    deinit {
        monitorCancellable?.cancel()
    }
}
```

- Note: This API requires iOS 13, macOS 10.15, tvOS 13, or watchOS 6
