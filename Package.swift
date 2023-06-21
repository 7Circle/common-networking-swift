// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonNetworking",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        .library(
            name: "CommonNetworking",
            targets: ["CommonNetworking"]),
    ],
    dependencies: [
        .package(url: "https://bitbucket.org/zero12srl/zero12-libraries-ios-test-utils.git", .upToNextMajor(from: "0.0.1"))
    ],
    targets: [
        .target(
            name: "CommonNetworking",
            dependencies: []),
        .testTarget(
            name: "CommonNetworkingTests",
            dependencies: [
                "CommonNetworking",
                .product(name: "Zero12TestUtils", package: "zero12-libraries-ios-test-utils")
            ],
            resources: [
                .copy("Mocks")
            ]),
    ]
)
