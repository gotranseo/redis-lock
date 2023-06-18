// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "redis-lock",
    products: [
        .library(
            name: "RedisLock",
            targets: ["RedisLock"]),
    ],
    dependencies: [
        .package(url: "https://gitlab.com/swift-server-community/RediStack.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "RedisLock",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                "RediStack",
            ]
        ),
        .testTarget(
            name: "RedisLockTests",
            dependencies: [
                "RedisLock",
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ]),
    ]
)
