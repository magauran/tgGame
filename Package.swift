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
        .package(url: "https://github.com/givip/Telegrammer.git", from: "0.4.0")
        ],
    targets: [
        .target( name: "tgGame", dependencies: ["Telegrammer"])
        ]
)
