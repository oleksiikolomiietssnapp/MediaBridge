// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MediaBridge",
    platforms: [
        .iOS(.v18)
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
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MediaBridgeTests",
            dependencies: ["MediaBridge"],
            path: "Tests",
        ),
    ]
)
