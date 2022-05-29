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
    <img src="https://img.shields.io/badge/Swift-5.6-critical" />
    <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-inactive" />
</p>

NetworkReachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). Because these APIs were originally written in C, they are old and cumbersome to use from Swift. NetworkReachability wraps these APIs in Swift and provides a modern interface for the most common use cases.

NetworkReachability supports synchronous reachability queries, as well as constant asynchronous reachability observation via the following mechanisms:

* Delegation
* Closures
* [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter)
* [Swift Structured Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
* [Combine](https://developer.apple.com/documentation/combine)

## Installation

NetworkReachability is currently distributed exclusively through the [Swift Package Manager](https://www.swift.org/package-manager/). 

To add NetworkReachability as a dependency to an existing Swift package, add the following line of code to the `dependencies` parameter of your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vsanthanam/NetworkReachability.git", .upToNextMajor(from: "2.0.0"))
]
```

To add NetworkReachability as a dependency to an Xcode Project: 

- Choose `File` → `Add Packages...`
- Enter package URL `https://github.com/vsanthanam/NetworkReachability.git` and select your release and of choice.

Other distribution mechanisms like CocoaPods or Carthage may be added in the future.

## Usage & Documentation

NetworkReachability's documentation is built with [DocC](https://developer.apple.com/documentation/docc) and included in the repository as a DocC archive. The latest version is hosted on [GitHub Pages](https://pages.github.com) and is available [here](https://reachability.tools/docs/documentation/networkreachability).

[![Documentation](Images/Documentation.svg)](https://reachability.tools/docs/documentation/networkreachability)
