// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-based-client",
    platforms: [
        .iOS(.v13), .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "BasedClient",
            targets: ["BasedClient"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Flight-School/AnyCodable",
            from: "0.6.2"
        ),
        .package(
            url: "https://github.com/mpsnp/swift-naked-json",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "BasedClient",
            dependencies: [
                "AnyCodable",
                .product(name: "NakedJson", package: "swift-naked-json"),
            ]
        ),
        .testTarget(
            name: "BasedClientTests",
            dependencies: [
                "BasedClient",
                .product(name: "NakedJson", package: "swift-naked-json"),
            ]
        ),
    ]
)
