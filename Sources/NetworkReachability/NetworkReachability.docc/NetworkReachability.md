# ``NetworkReachability``

A Swift replacement for `SCNetworkReachability` & `NWPathMonitor` with support for structured concurrency.

NetworkReachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). Because these APIs were originally written in C, they are old and cumbersome to use from Swift. In 2018, Apple added the [Network](https://developer.apple.com/documentation/network) framework which introduced the [`NWPathMonitor`](https://developer.apple.com/documentation/network/nwpathmonitor) class. This API addressed some of the problems with [`SCNetworkReachability`](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift), but was still cumbersome to integrate into many commonly used app patterns. NetworkReachability wraps both these APIs in an easy to use Swift wrapper with similar interfaces and features sthat will be familiar to most iOS developers.
NetworkReachability supports with the following Apple platform releases:

* iOS 11.0 - 15.x
* macOS 10.13 - 12.x
* tvOS 11.0 - 15.x
* watchOS 4.0 - 8.x

## Usage

To determine the current reachability status. Initialize an instance of ``ReachabilityMonitor`` or ``NetworkMonitor`` and retain it in memory. You can also pass in an optional delegate or update handler to recieve reachability status updates on the main thread. Both classes also fire notifications through `NotificationCenter.default`.
