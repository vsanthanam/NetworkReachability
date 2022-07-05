# ``NetworkReachability``

A Swift replacement for `SCNetworkReachability` & `NWPathMonitor` with support for structured concurrency.

NetworkReachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). Because these APIs were originally written in C, they are old and cumbersome to use from Swift. In 2018, Apple added the [Network](https://developer.apple.com/documentation/network) framework which introduced the [`NWPathMonitor`](https://developer.apple.com/documentation/network/nwpathmonitor) class. This API addressed some of the problems with [`SCNetworkReachability`](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift), but was still cumbersome to integrate into many commonly used app patterns. NetworkReachability wraps both these APIs in an easy to use Swift wrapper with similar interfaces and features sthat will be familiar to most iOS developers.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:Tutorials>

### Network Monitor

- <doc:NetworkMonitorGuide>
- ``NetworkMonitor``
- ``NetworkMonitorDelegate``

### Reachability Monitor

- <doc:ReachabilityMonitorGuide>
- ``ReachabilityMonitor``
- ``ReachabilityMonitorDelegate``
- ``Reachability``

### Other

- <doc:RxSwift>
