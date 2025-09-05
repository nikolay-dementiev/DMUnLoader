// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// good 3rd party Activity indicators: https://github.com/MojtabaHs/ActivityIndicator-SwiftUI

import PackageDescription

let package = Package(
    name: "DMUnLoader",
    platforms: [
        .iOS(.v17),
        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DMUnLoader",
            type: .dynamic,
            targets: ["DMUnLoader"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/GayleDunham/SwiftLintPlugin.git", branch: "main"),
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.1"),
        .package(url: "https://github.com/nikolay-dementiev/DMAction.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DMUnLoader",
            dependencies: ["DMAction"],
            path: "Sources",
            sources: ["DMUnLoader"],
            plugins: [ .plugin(name: "SwiftLintBuildTool", package: "SwiftLintPlugin") ]
        ),
        .testTarget(
            name: "DMUnLoaderTests",
            dependencies: ["DMUnLoader",
                           "ViewInspector",
                           "DMAction"],
            path: "Tests",
            plugins: [ .plugin(name: "SwiftLintBuildTool", package: "SwiftLintPlugin") ]
        ),
    ]
)
