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
        .package(url: "https://github.com/zmeyc/telegram-bot-swift.git", .branch("dev")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "tgGame",
            dependencies: ["TelegramBotSDK"]),
        .testTarget(
            name: "tgGameTests",
            dependencies: ["tgGame"]),
    ]
)