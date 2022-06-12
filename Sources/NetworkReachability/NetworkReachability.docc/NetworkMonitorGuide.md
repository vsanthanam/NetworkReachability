# NetworkMonitor Guide

Learn how to observe reachability changes with Swift Concurrency


## Overview

The easiest way to use a ``NetworkMonitor`` is to initialize an instance and retain it memory.
From there you can access the `currentPath` property whenever you need to know the last known network path.

```swift
import NetworkReachability

let monitor = NetworkMonitor()
let path = monitor.currentPath
```


This API is simply enough for many uses cases, but ``NetworkMonitor`` offers a few other APIs to observe up-to-date network path changes as they happen.

### Retrieving the current network path

``NetworkMonitor`` allows you to retrieve the last known network path using two asyncronous APIs. Unlike the synchronous API described above which may or may not be up to date, the asynchronous APIs gaurantee you access to an up-to-date value.

##### Closures

```swift
func updateReachability() {
    NetworkMonitor.networkPath(completionHandler: { (path: NWPath) in 
        // Do something with `path`
    }
}
```

##### Swift Concurrency

```swift
func updateReachability() {
    Task {
        let path = await NetworkMonitor.networkPath
        // Do something with `path`
    }
}
```

### Observing network path updates

If you need to observe all network path changes, ``NetworkMonitor`` provides several asynchronous APIs that will allow you to integrate network path data into any existing pipeline

##### Closures

```swift
import Network
import NetworkReachability

final class MyClass {

    var monitor: NetworkMonitor?

    func startMonitoring() {
        stopMonitoring()
        monitor = NetworkMonitor(updateHandler: { (monitor: NetworkMonitor, path: NWPath) in
            // Do something with `monitor` or `path`
        }
    }

    func stopMonitoring() {
        monitor = nil
    }

}
```

##### Swift Concurrency

```swift
import Network
import NetworkReachability

final class MyClass {
    
    var monitorTask: Task?

    func startObserving() {
        stopObserving()
        monitorTask = Task {
            for await path in NetworkMonitor.networkMonitorUpdates {
                // Do something with `path`
            }
        }
    }

    func startObserving() {
        monitorTask?.cancel()
        monitorTask = nil
    }
}
```

##### Delegation

```swift
import Network
import NetworkReachability

final class MyClass: NetworkMonitorDelegate {

    var monitor: NetworkMonitor?

    func startMonitoring() {
        stopMonitoring()
        monitor = NetworkMonitor(delegate: self)
    }

    func stopMonitoring() {
        monitor = nil
    }

    func networkMonitor(_ monitor: NetworkMonitor, didUpdateNetworkPath networkPath: NWPath) {
        // Do something with `networkPath`
    }

}
```

##### NotificationCenter

```swift
import Foundation
import Network
import NetworkReachability

final class MyClass: NetworkMonitorDelegate {

    var monitor: NetworkMonitor?

    func startMonitoring() {
        stopMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdate:), name: .networkPathChanged)
        monitor = NetworkMonitor()
    }

    func stopMonitoring() {
        monitor = nil
        NotificationCenter.default.removeObserver(self, name: .networkPathChanged)
    }

    @objc
    func handleUpdate(_ notification: Notification) {
        guard let monitor = notification.object as? NetworkMonitor else {
            return
        }
        let path = monitor.currentPath
        // Do something with `path`
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .networkPathChanged)
    }

}
```

##### Combine

```swift
import Combine
import Network
import NetworkReachability

final class MyClass {
    
    var monitorCancellable: AnyCancellable?

    func startObserving() {
        stopObserving()
        monitorCancellable = NetworkMonitor.networkPathPublisher
            .map(\.status)
            .sink { status in
                // Do something with `status`
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
