// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-based-client",
    platforms: [
      .iOS(.v13)
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
        )
    ],
    targets: [
        .target(
            name: "BasedClient",
            dependencies: ["AnyCodable"]),
        .testTarget(
            name: "BasedClientTests",
            dependencies: ["BasedClient"]),
    ]
)
