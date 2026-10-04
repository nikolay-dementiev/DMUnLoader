// swift-tools-version: 6.0
//
// A package that uses DMUnLoader the way an app does: only the public interface, no test
// hooks. It is compiled in Swift 6 and in Swift 5 language mode.

import PackageDescription

let package = Package(
    name: "Consumer",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ConsumerSwift6", targets: ["ConsumerSwift6"]),
        .library(name: "ConsumerSwift5", targets: ["ConsumerSwift5"])
    ],
    dependencies: [
        .package(name: "DMUnLoader", path: "../..")
    ],
    targets: [
        .target(
            name: "ConsumerSwift6",
            dependencies: [.product(name: "DMUnLoader", package: "DMUnLoader")]
        ),
        .target(
            name: "ConsumerSwift5",
            dependencies: [.product(name: "DMUnLoader", package: "DMUnLoader")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
