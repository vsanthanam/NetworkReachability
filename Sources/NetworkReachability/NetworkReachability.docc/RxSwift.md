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

In addition to this package, you must also add the main NetworkReachability package, as well as RxSwift. This package dependends on, but includes interfaces for neither.

### Usage

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
