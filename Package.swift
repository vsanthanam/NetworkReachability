// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkReachability",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "NetworkReachability",
            targets: ["NetworkReachability"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", exact: "0.53.5")
    ],
    targets: [
        .target(
            name: "NetworkReachability",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkReachabilityTests",
            dependencies: ["NetworkReachability"]
        ),
    ]
)
