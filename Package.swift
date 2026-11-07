// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// good 3rd party Activity indicators: https://github.com/MojtabaHs/ActivityIndicator-SwiftUI

import PackageDescription

// Every target compiles with these. devkit.conf repeats them in SWIFT_FLAGS.
let swiftSettings: [SwiftSetting] = [.enableUpcomingFeature("ExistentialAny")]

let package = Package(
    name: "DMUnLoader",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
//        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DMUnLoader",
            // Kept dynamic (decided 2026-11-07). One copy of the library then serves an app and its
            // extensions, or several frameworks that link it, and a project that embeds the framework
            // keeps building (with the type left unspecified, Xcode 27.2 linked it statically and the
            // embed entry failed the build in the measurement project). Measured against that on an
            // iPhone 13 Pro (iOS 27.2): no measured difference to the first frame, 0.9 ms more before
            // main, an unsigned app 0.18 to 0.24 MB larger. Not worth the break.
            type: .dynamic,
            targets: ["DMUnLoader"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", .upToNextMinor(from: "0.10.5")),
        .package(url: "https://github.com/nikolay-dementiev/DMAction.git", from: "1.1.0"),
        .package(url: "https://github.com/nikolay-dementiev/DMVariableBlurView.git", from: "1.1.0"),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.12.0"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DMUnLoader",
            dependencies: [
                "DMAction",
                "DMVariableBlurView"
            ],
            resources: [.process("Resources")],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "DMUnLoaderTests",
            dependencies: [
                "DMUnLoader",
                "ViewInspector",
                "DMAction",
                "DMVariableBlurView",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Tests",
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)
