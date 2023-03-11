// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonNetworking",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CommonNetworking",
            targets: ["CommonNetworking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/WeTransfer/Mocker.git", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        .target(
            name: "CommonNetworking",
            dependencies: ["Mocker"]),
        .testTarget(
            name: "CommonNetworkingTests",
            dependencies: ["CommonNetworking"],
            resources: [
                .copy("Mocks")
            ]),
    ]
)
