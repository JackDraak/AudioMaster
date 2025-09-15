// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AudioMaster",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AudioMaster",
            targets: ["AudioMaster"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AudioMaster",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "AudioMasterTests",
            dependencies: ["AudioMaster"],
            path: "Tests"
        ),
    ]
)