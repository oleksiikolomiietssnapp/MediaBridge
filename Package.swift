// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MediaBridge",
    platforms: [
        .iOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "MediaBridge",
            targets: ["MediaBridge"]
        )
    ],
    targets: [
        .target(
            name: "MediaBridge",
            path: "Sources"
        ),
        .testTarget(
            name: "MediaBridgeTests",
            dependencies: ["MediaBridge"],
            path: "Tests"
        )
    ]
)
