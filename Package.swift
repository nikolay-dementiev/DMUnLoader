// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// good 3rd party Activity indicators: https://github.com/MojtabaHs/ActivityIndicator-SwiftUI

import PackageDescription

let package = Package(
    name: "DMErrorHandling",
//    defaultLocalization: "en",
    platforms: [
//        .macOS(.v10_13),
        .iOS(.v16),
//        .tvOS(.v12),
        .watchOS(.v7),
//        .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DMErrorHandling",
            type: .dynamic,
            targets: ["DMErrorHandling"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/GayleDunham/SwiftLintPlugin.git", branch: "main"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DMErrorHandling",
            path: "Sources",
            exclude: [
                "Deprecated"
                /*,"Examples"*/
                     /*,"Sources/DMErrorHandling/Helpers/Extensions"*/
            ],
            plugins: [ .plugin(name: "SwiftLintBuildTool", package: "SwiftLintPlugin") ]
        ),
        .testTarget(
            name: "DMErrorHandlingTests",
            dependencies: ["DMErrorHandling",
                           "Nimble",
                           "Quick"],
            path: "Tests",
            plugins: [ .plugin(name: "SwiftLintBuildTool", package: "SwiftLintPlugin") ]
        ),
    ]
)
