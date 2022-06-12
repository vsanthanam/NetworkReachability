# NetworkReachability with RxSwift

Learn how to observe reachability changes with RxSwift

## Overview

NetworkReachability supports [RxSwift](https://github.com/ReactiveX/RxSwift) bindings using a separate optional package, [NetworkReachabilityRxSwift](https://github.com/vsanthanam/NetworkReachabilityRxSwift).

To add NetworkReachabilityRxSwift as a dependency to an existing Swift package, add the following line of code to the `dependencies` parameter of your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vsanthanam/NetworkReachabilityRxSwift.git", from: "1.0.0")
]
```

To add NetworkReachabilityRxSwift as a dependency to an Xcode Project: 

- Choose `File` → `Add Packages...`
- Enter package URL `https://github.com/vsanthanam/NetworkReachabilityRxSwift.git` and select your release of choice.

Other distribution mechanisms like CocoaPods or Carthage may be added in the future.

### NetworkMonitor + RxSwift

```swift
import Network
import NetworkReachability
import NetworkReachabilityRxSwift
import RxSwift

final class MyClass {
    
    var disposable: Disposable?

    func startObserving() {
        stopObserving()
        disposable = NetworkMonitor
            .observableNetworkPath
            .map(\.status)
            .distinctUntilChanged()
            .subscribe(onNext: { status in
                // Do something with `status`
            })
    }

    func stopObserving() {
        disposable?.dispose()
        disposable = nil
    }

    deinit {
        disposable?.dispose
    }

}
```

### ReachabilityMonitor + RxSwift

```swift
import NetworkReachability
import NetworkReachabilityRxSwift
import RxSwift

final class MyClass {
    
    var disposable: Disposable?

    func startObserving() {
        stopObserving()
        disposable = ReachabilityMonitor
            .observableReachability
            .map(\.status.isReachable)
            .distinctUntilChanged()
            .catchError { _ in Observable.empty() }
            .subscribe(onNext: { isReachable in
                // Do something with `isReachable`
            })
    }

    func stopObserving() {
        disposable?.dispose()
        disposable = nil
    }

    deinit {
        disposable?.dispose
    }

}
```
