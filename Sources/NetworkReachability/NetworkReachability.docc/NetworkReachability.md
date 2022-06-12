# ``NetworkReachability``

A Swift replacement for `SCNetworkReachability` & `NWPathMonitor` with support for structured concurrency.

NetworkReachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). Because these APIs were originally written in C, they are old and cumbersome to use from Swift. In 2018, Apple added the [Network](https://developer.apple.com/documentation/network) framework which introduced the [`NWPathMonitor`](https://developer.apple.com/documentation/network/nwpathmonitor) class. This API addressed some of the problems with [`SCNetworkReachability`](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift), but was still cumbersome to integrate into many commonly used app patterns. NetworkReachability wraps both these APIs in an easy to use Swift wrapper with similar interfaces and features sthat will be familiar to most iOS developers.

## Usage

To determine the current reachability status. Initialize an instance of ``ReachabilityMonitor`` or ``NetworkMonitor`` and retain it in memory. Both classes support a number of observability mechanisms and should be easy to integrate into your data pipelines.

## Essentials

- <doc:GettingStarted>
- <doc:NetworkMonitorGuide>
- <doc:ReachabilityMonitorGuide>

## Topics

### Network Monitor

- ``NetworkMonitor``
- ``NetworkMonitorDelegate``

### Reachability Monitor

- ``ReachabilityMonitor``
- ``ReachabilityMonitorDelegate``
- ``Reachability``
