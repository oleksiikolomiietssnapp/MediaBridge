// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MediaBridge",
    products: [
        .library(
            name: "MediaBridge",
            targets: ["MediaBridge"]
        ),
    ],
    targets: [
        .target(
            name: "MediaBridge"
        ),
        .testTarget(
            name: "MediaBridgeTests",
            dependencies: ["MediaBridge"]
        ),
    ]
)
