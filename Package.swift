// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Talon",
    products: [
        .library(
            name: "Talon",
            targets: ["Talon"]),
    ],
    dependencies: [
        .package(url: "https://github.com/GEOSwift/GEOSwift", from: "7.2.0"),
        .package(url: "https://github.com/Mordil/RediStack", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "Talon",
            dependencies: [
                .product(name: "RediStack", package: "RediStack"),
                .product(name: "GEOSwift", package: "GEOSwift"),
            ]),
        .testTarget(
            name: "TalonTests",
            dependencies: ["Talon"]),
    ]
)
