# Network Monitor Programming Guide

Learn how to use Network Monitor APIs

## Overview

The easiest way to use a ``NetworkMonitor`` is to initialize an instance and retain it memory.
From there you can access the `currentPath` property whenever you need to know the last known network path.

```swift
import Network
import NetworkReachability

let monitor = NetworkMonitor()
let path = monitor.currentPath
```

This synchronous API is easy to use, but `currentPath` isn't always up-to-date and is best used when a monitor instance has been retained in memory for some time. As such, it will be insufficient for many use cases and is not recommended.

Instead, ``NetworkMonitor`` offers a variety of asynchronous APIs for both single value retrieval as well as constant value observation that are gauranteed to offer up-to-date values.

### Retrieving the current network path

``NetworkMonitor`` allows you to retrieve the last known network path using two asyncronous APIs. Unlike the synchronous API described above which provides values that may or may not be up to date, the asynchronous APIs gaurantee you access to an up-to-date value.

##### Closures

To asynchronously retrieve the last known network path, you can use the `networkPath(completionHandler:)` static method. The provided closure will be executed exactly once.

```swift
import Network
import NetworkReachability

func updateReachability() {
    NetworkMonitor.networkPath(completionHandler: { (path: NWPath) in 
        // Do something with `path`
    }
}
```

- Important: `completionHandler` is always called in the main thread.

##### Swift Concurrency

You can also retrieve the last known network path using Swift Concurrency via the `networkPath` static property.

```swift
import Network
import NetworkReachability

func updateReachability() {
    Task {
        let path = await NetworkMonitor.networkPath
        // Do something with `path`
    }
}
```

- Note: This API requires iOS 13, macOS 10.15, tvOS 13, or watchOS 6

### Observing network path updates

If you need to observe all network path changes, ``NetworkMonitor`` provides several asynchronous APIs that will allow you to integrate network path data into any existing pipeline

##### Closures

You can use a closure to observe network path updates over time. You can pass in the closure on initialization, or add one later using the `updateHandler` property.

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

- Important: By default, instances of ``NetworkMonitor`` always update handler on the main thread. You can change this behavior by setting the monitor's `.updateQueue` property.

##### Swift Concurrency

You can use an `AsyncSequence` to observe network path updates over time using Swift Concurrency

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

- Note: This API requires iOS 13, macOS 10.15, tvOS 13, or watchOS 6

##### Delegation

You can use ``NetworkMonitorDelegate`` to recieve callbacks when the network path changes. You can pass in a delegate object when the monitor is initialized, or you can assign one later.

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

    // MARK: - NetworkMonitorDelegate

    func networkMonitor(_ monitor: NetworkMonitor, didUpdateNetworkPath networkPath: NWPath) {
        // Do something with `networkPath`
    }

}
```

- Important: By default, instances of ``NetworkMonitor`` always call execute their delegate callbacks on the main thread. You can change this behavior by setting the monitor's `.updateQueue` property.

##### NotificationCenter

If you have retained an instance of ``NetworkMonitor`` in memory, but do not have access to it in the part of your code that needs network path updates, you can 
observe network path changes by observing notifications with the name `Notification.Name.networkPathChanged` on the default notification center. The notification's `.object` property will contain the ``NetworkMonitor``. From there, you can use `currentPath` property of the monitor, which you now know will be up-to-date thanks to the notification.

```swift
import Foundation
import Network
import NetworkReachability

final class MyClass {

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

- Important: By default, instances of ``NetworkMonitor`` always post their notifications on the main thread. You can change this behavior by setting the monitor's `.updateQueue` property.

##### Combine

You can observe network path changes using a [Combine](https://developer.apple.com/documentation/combine) with the `networkPathPublisher` static property.

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

- Note: This API requires iOS 13, macOS 10.15, tvOS 13, or watchOS 6
