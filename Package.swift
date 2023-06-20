// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "redis-lock",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "RedisLock",
            targets: ["RedisLock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/RediStack.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.54.0"),
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
