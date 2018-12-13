// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tgGame",
    products: [
        .executable(
            name: "tgGame",
            targets: ["tgGame"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/givip/Telegrammer.git", from: "0.4.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/database-kit.git", from: "1.0.0")
        ],
    targets: [
        .target( name: "tgGame", dependencies: ["Vapor", "Telegrammer", "Redis", "DatabaseKit"])
        ]
)
