# Getting Started with NetworkReachability

Choose between the two APIs included with NetworkReachability

## Overview

NetworkReachability consists of two main classes, ``NetworkMonitor`` and ``ReachabilityMonitor``

``NetworkMonitor`` is built on Apple's [Network](https://developer.apple.com/documentation/network) framework. As such, it requires iOS 12 and returns [`NWPath`](https://developer.apple.com/documentation/network/nwpath) types.

``ReachabilityMonitor`` is built on [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration), and returns a ``Reachability`` struct which wraps [``SCNetworkReachabilityFlags``](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachabilityflags). As such, it does not support watchOS.

These APIs are very similar, and can generally be used interchangeably. Like Apple's APIs, ``ReachabilityMonitor`` offers a synchronous & asynchronous APIs, and is capable of throwing errors. ``NetworkMonitor`` monitor is simpler and more powerful, but does not offer a reliable synchronous API.

| API                       | Single Value | Observing Values  | Throws Errors | macOS  | iOS   | watchOS | tvOS  |
| ------------------------- | ------------ | ----------------- | ------------- | ------ | ----- | ------- | ----- |
| ``NetworkMonitor``        | Async        | Async             | No            | 10.14+ | 12.0+ | N/A     | 12.0+ |
| ``ReachabilityMonitor``   | Sync         | Async             | Yes           | 10.13+ | 11.0+ | 4.0+    | 11.0+ |

I recommend that you use ``NetworkMonitor`` as it both simpler and more robust, unless you need to target iOS 11 or you absolutely need a synchronous API.

Both APIs still offer the same observability mechanisms:

* [Delegation](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Delegation.html)
* [Closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html)
* [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter)
* [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
* [Combine](https://developer.apple.com/documentation/combine)

To learn more about ``NetworkMonitor``, see the <doc:NetworkMonitorGuide>.

To learn more about ``ReachabilityMonitor``, see the <doc:ReachabilityMonitorGuide>
