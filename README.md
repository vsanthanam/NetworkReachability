# NetworkReachability

<p align="center">
    <img width="330" height="190" src="Images/Card.svg">
    <br />
    <br />
    <a href="https://github.com/vsanthanam/NetworkReachability/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/vsanthanam/NetworkReachability" />
    </a>
    <a href="https://github.com/vsanthanam/NetworkReachability/releases">
        <img src="https://img.shields.io/github/v/release/vsanthanam/NetworkReachability" />
    </a>
    <a href="https://github.com/vsanthanam/NetworkReachability/actions/workflows/swift.yml">
        <img src="https://img.shields.io/github/workflow/status/vsanthanam/NetworkReachability/Swift" />
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.6-critical" />
    </a>
    <a href="https://developer.apple.com">
        <img src="https://img.shields.io/badge/platform-iOS%2011%20%7C%20macOS%2012.13%20%7C%20tvOS%2011%20%7C%20watchOS%204-lightgrey" />
    </a>
</p>

NetworkReachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). Because these APIs were originally written in C, they are old and cumbersome to use from Swift. In 2018, Apple added the [Network](https://developer.apple.com/documentation/network) framework which introduced the [`NWPathMonitor`](https://developer.apple.com/documentation/network/nwpathmonitor) class. This API addressed some of the problems with [`SCNetworkReachability`](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift), but was still cumbersome to integrate into many commonly used app patterns. NetworkReachability wraps both these APIs in an easy to use Swift wrapper with similar interfaces and features sthat will be familiar to most iOS developers.

NetworkReachability supports synchronous reachability queries, as well as constant asynchronous reachability observation via the following mechanisms:

* [Delegation](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Delegation.html)
* [Closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html)
* [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter)
* [Swift Structured Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
* [Combine](https://developer.apple.com/documentation/combine)

## Installation

NetworkReachability is currently distributed exclusively through the [Swift Package Manager](https://www.swift.org/package-manager/). 

To add NetworkReachability as a dependency to an existing Swift package, add the following line of code to the `dependencies` parameter of your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vsanthanam/NetworkReachability.git", .upToNextMajor(from: "1.0.0"))
]
```

To add NetworkReachability as a dependency to an Xcode Project: 

- Choose `File` → `Add Packages...`
- Enter package URL `https://github.com/vsanthanam/NetworkReachability.git` and select your release of choice.

Other distribution mechanisms like CocoaPods or Carthage may be added in the future.

## Usage & Documentation

NetworkReachability's documentation is built with [DocC](https://developer.apple.com/documentation/docc) and included in the repository as a DocC archive. The latest version is hosted on [GitHub Pages](https://pages.github.com) and is available [here](https://reachability.tools/docs/documentation/networkreachability).

[![Documentation](Images/Documentation.svg)](https://reachability.tools/docs/documentation/networkreachability)
