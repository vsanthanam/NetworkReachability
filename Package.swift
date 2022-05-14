// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReachabilityMonitor",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "ReachabilityMonitor",
            targets: ["ReachabilityMonitor"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ReachabilityMonitor",
            dependencies: []
        ),
        .testTarget(
            name: "ReachabilityMonitorTests",
            dependencies: ["ReachabilityMonitor"]
        ),
    ]
)
