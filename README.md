# Reachability

Reachability is a replacement for Apple's [SystemConfiguration](https://developer.apple.com/documentation/systemconfiguration) [Network Reachability APIs](https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability?language=swift). These APIs were originally written in C and are old, cumbersome to use, and do not play nicely with many modern Swift language patterns. Reachability wraps these APIs in Swift and provides a modern interface for the most common use cases.

Reachability supports with the following Apple platform releases:

* iOS 13.0 - 15.x
* macOS 10.15 - 13.x
* tvOS 13.0 - 15.x
* watchOS 13.0 - 15.x

Reachability supports synchronous reachability queries, as well as constant asynchronous reachability observation via the following mechanisms:

* Delegation
* Closures
* [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter)
* [Swift Structured Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
* [Combine](https://developer.apple.com/documentation/combine)

Large parts of the library's design are inspired by [this project](https://github.com/ashleymills/Reachability.swift), which was written before Swift 5.5 and the introduction of structured concurrency.

## Installation

Reachability is currently distributed exclusively through the [Swift Package Manager](https://www.swift.org/package-manager/). 

To add Reachability as a dependency to an existing Swift package, add the following line of code to the `packages` parameter of your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vsanthanam/Reachability.git", .upToNextMajor(from: "1.0.0"))
]
```

To add Reachability as a dependency to an Xcode Project: 

- Choose File -> Swift Packages -> Add Package Dependency...
- Enter package URL `https://github.com/vsanthanam/Reachability.git` and select your release and of choice.

Other distribution mechanisms like CocoaPods or Carthage may be added in the future.

## Usage & Documentation

Reachability's documentation is built with [DocC](https://developer.apple.com/documentation/docc) and included in the repository as a DocC archive. The latest version is hosted on [GitHub Pages](https://pages.github.com) and is available [here](https://vsanthanam.github.io/Reachability/docs/documentation/reachability).
