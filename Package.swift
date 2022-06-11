// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkReachability",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "NetworkReachability",
            targets: ["NetworkReachability"]
        ),
        .library(
            name: "NetworkReachabilityRxSwift",
            targets: ["NetworkReachabilityRxSwift"]
        ),
        .library(
            name: "NetworkReachabilityShared",
            targets: ["NetworkReachabilityShared"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "NetworkReachability",
            dependencies: ["NetworkReachabilityShared"]
        ),
        .testTarget(
            name: "NetworkReachabilityTests",
            dependencies: ["NetworkReachability"]
        ),
        .target(
            name: "NetworkReachabilityRxSwift",
            dependencies: ["NetworkReachability", "NetworkReachabilityShared", "RxSwift"]
        ),
        .testTarget(
            name: "NetworkReachabilityRxSwiftTests",
            dependencies: ["NetworkReachability", "NetworkReachabilityRxSwift", "RxSwift"]
        ),
        .target(
            name: "NetworkReachabilityShared",
            dependencies: []
        ),

    ]
)
