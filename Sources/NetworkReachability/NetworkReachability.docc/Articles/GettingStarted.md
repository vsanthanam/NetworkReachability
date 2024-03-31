# Getting Started with NetworkReachability

Choose between the two APIs included with NetworkReachability

## Overview

``NetworkMonitor`` is built on Apple's [Network](https://developer.apple.com/documentation/network) framework. As such, it requires iOS 12 and returns [`NWPath`](https://developer.apple.com/documentation/network/nwpath) types.

The APIs still offer the same observability mechanisms:

* [Delegation](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Delegation.html)
* [Closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html)
* [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter)
* [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
* [Combine](https://developer.apple.com/documentation/combine)

### Learn More

* To learn more about ``NetworkMonitor``, see the <doc:NetworkMonitorGuide>.
