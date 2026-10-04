# DMUnLoader

A HUD for the loading, success and failure states of an iOS app, for SwiftUI and UIKit.

[![CI](https://github.com/nikolay-dementiev/DMUnLoader/actions/workflows/ci.yml/badge.svg)](https://github.com/nikolay-dementiev/DMUnLoader/actions/workflows/ci.yml)
[![Swift 6.2+](https://img.shields.io/badge/Swift-6.2%2B-orange?style=flat-square)](#requirements)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_17%2B-yellowgreen?style=flat-square)](#requirements)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader?ref=badge_shield)

<p align="center">
  <img src="./DocumentationAndBluePrints/Assets/DMUnloade_mainImage.png?raw=true" alt="DMUnLoader SDK logo" style="max-height: 400px; aspect-ratio: 1536/1024; object-fit: scale-down;">
</p>

- [What it is](#what-it-is)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Usage](#usage)
- [Configuration](#configuration)
- [Behaviour your app must know](#behaviour-your-app-must-know)
- [Example app and tests](#example-app-and-tests)
- [Versions and migration](#versions-and-migration)
- [Known issues](#known-issues)
- [The family](#the-family)
- [Contributing, security, licence](#contributing-security-licence)

## What it is

DMUnLoader shows one HUD at a time over a scene of your app: a spinner while work runs, then a
success, or a failure with Close and an optional Retry. A loading manager holds the state, and
your code calls it: `showLoading`, `showSuccess`, `showFailure` and `hide`. The HUD is drawn in a
window of its own above the scene, and while it is shown it takes the touches of the scene, so
the user waits for the result. The views of the states are the library's, with your settings, or
your own.

<p align="center">
  <img src="./DocumentationAndBluePrints/Assets/TestProject-ScreenRecording/Loadiing-Default+Custom-Recording.gif?raw=true" alt="Two phone screens, the default settings on the left and custom settings on the right. A tap shows the loading HUD over the blurred screen, a card with a spinner and the loading text, yellow on the right, and then a success card with a checkmark and the text Successfully completed, which hides by itself." style="max-height: 500px; aspect-ratio: 640/694; object-fit: scale-down;">
</p>

Use it when an operation blocks the screen: a sign-in, a payment, a save that the user waits for
before going on.

When not to use it:

- For progress that must not block the screen. While a HUD is shown, the content under it
  receives no touch: put a `ProgressView` in your view instead.
- For several operations at once, each with its own progress: a scene shows one state at a time.
- If your app must not contain a private API of the system. The default backdrop is the variable
  blur of DMVariableBlurView, which uses one, and DMUnLoader depends on DMVariableBlurView, so its
  code stays in your app whatever backdrop you choose. See [Backdrop](#backdrop).

## Requirements

- Swift 6.2 or later, which is Xcode 26.0 or later.
- iOS 17 or later.

What each version is verified with:

| What | How |
|---|---|
| iOS 26.5 and 26.2 (Xcode 26.6) | the tests of the package run on simulators in CI |
| iOS 26.5 (Xcode 26.6) and 18.6 (Xcode 26.3) | the tests of the example app, hosted and UI tests, run on simulators in CI |
| iOS 17.5, 18.6 and 26.5 (Xcode 26.6) | the tests of the package and of the example app ran on simulators for 1.1.0; iOS 17.5 runs before each release |
| iPadOS 26.2 (Xcode 26.6) | the tests of the example app, two scenes included, run on an iPad simulator before each release |
| Swift 6.2 (Xcode 26.0.1) | CI compiles the library with that compiler; no test runs with it |

## Installation

### Swift Package Manager

In Xcode, choose File > Add Package Dependencies and enter
`https://github.com/nikolay-dementiev/DMUnLoader`. In a package manifest:

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(url: "https://github.com/nikolay-dementiev/DMUnLoader.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: [
                .product(name: "DMUnLoader", package: "DMUnLoader")
            ]
        )
    ]
)
```

DMUnLoader brings [DMAction](https://github.com/nikolay-dementiev/DMAction) and
[DMVariableBlurView](https://github.com/nikolay-dementiev/DMVariableBlurView) with it. The
libraries that only its tests use are not fetched for your app.

### CocoaPods

```ruby
pod 'DMUnLoader', '1.1.0'
```

Version 1.1.0 is the last release published to the CocoaPods trunk, which becomes read-only on
2 December 2026. Later releases come through Swift Package Manager only. The podspec stays in the
repository, and CI lints it.

## Quick start

```swift
import DMUnLoader
import SwiftUI

@main
struct QuickStartApp: App {
    @StateObject private var loadingManager = DMLoadingManagerMain()

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView(manager: loadingManager) { manager in
                LoadButton(loadingManager: manager)
            }
        }
    }
}

struct LoadButton: View {
    let loadingManager: DMLoadingManagerMain
    private let provider = DefaultDMLoadingViewProvider()

    var body: some View {
        Button("Load") {
            loadingManager.showLoading(provider: provider)
            Task {
                do {
                    let message = try await loadMessage()
                    loadingManager.showSuccess(message, provider: provider)
                } catch {
                    loadingManager.showFailure(error, provider: provider)
                }
            }
        }
    }
}

// A stand-in for your own work.
func loadMessage() async throws -> String {
    try await Task.sleep(for: .seconds(1))
    return "Loaded"
}
```

A tap shows the spinner, then the success, which hides by itself after 2 seconds.

## Usage

### SwiftUI with a manager your app owns

`DMRootLoadingView(manager:content:)`, as in the quick start, shows the HUD of the manager you
give it over the scene of the window the view is in. It needs no app delegate of DMUnLoader.
Keep the manager alive outside the view, as the `@StateObject` does, and use one such view per
scene: the HUD of each view joins the scene of that view. Another manager given in a later update
takes over the HUD.

### SwiftUI with the app delegate of DMUnLoader

`DMRootLoadingView(content:)` creates the loading manager itself and passes it to your content.
It needs the app delegate: `DMAppDelegateType`, or `DMAppDelegate<YourManager>` for a manager type
of your own, puts the scene delegate of DMUnLoader into the environment. Without it SwiftUI stops
the app when the view appears.

```swift
import DMUnLoader
import SwiftUI

@main
struct ExampleApp: App {
    @UIApplicationDelegateAdaptor private var delegate: DMAppDelegateType

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView { loadingManager in
                ContentView(loadingManager: loadingManager)
            }
        }
    }
}

struct ContentView: View {
    let loadingManager: DMLoadingManagerMain
    private let provider = DefaultDMLoadingViewProvider()

    var body: some View {
        Button("Show success") {
            loadingManager.showSuccess("Data loaded", provider: provider)
        }
    }
}
```

### UIKit

The UIKit integration installs `DMSceneDelegateTypeUIKit` as the scene delegate.
`DMSceneDelegateHelper` supplies the root view controller and receives the loading manager.

```swift
import UIKit
import DMUnLoader

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = DMSceneDelegateTypeUIKit<AppDelegateHelper>.self
        return configuration
    }
}

@MainActor
struct AppDelegateHelper {}

extension AppDelegateHelper: @MainActor DMSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(
        loadingManager: LM
    ) -> UIViewController {
        LoadingViewController(loadingManager: loadingManager)
    }
}

final class LoadingViewController<LM: DMLoadingManager>: UIViewController {
    private let loadingManager: LM
    private let provider = DefaultDMLoadingViewProvider()

    init(loadingManager: LM) {
        self.loadingManager = loadingManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unavailable")
    }

    override func loadView() {
        let button = UIButton(type: .system)
        button.setTitle("Show success", for: .normal)
        button.addTarget(self, action: #selector(showSuccess), for: .touchUpInside)
        view = button
    }

    @objc
    private func showSuccess() {
        loadingManager.showSuccess("Data successfully loaded!", provider: provider)
    }
}
```

The requirement keeps its released name, `makeUIKitRootViewHierarhy`, until 2.0.0. DMUnLoader
calls it on the main actor, so make the helper a `@MainActor` type that conforms with
`@MainActor DMSceneDelegateHelper`, as above: in Swift 6 mode a plain conformance stops with
"sending 'loadingManager' risks causing data races". The scene delegate creates its loading
manager with `init()`, so with `DMLoadingManagerMain` it has the default settings.

### Showing the states

- `showLoading(provider:)` shows the spinner until the next state.
- `showSuccess(_:provider:)` shows a message: any `DMLoadableTypeSuccess`, a `String` included.
- `showFailure(_:provider:onRetry:)` shows a failure. The library's error view shows the title of
  the error settings, the error's `localizedDescription`, Close, and Retry when `onRetry` is
  given. `showFailure(_:provider:)` shows a failure without Retry.
- `hide()` removes the HUD.

Retry runs your action and leaves the HUD as it is, so the action shows the next state itself:

```swift
import DMUnLoader
import Foundation

@MainActor
final class DownloadModel {
    private let loadingManager: DMLoadingManagerMain
    private let provider = DefaultDMLoadingViewProvider()

    init(loadingManager: DMLoadingManagerMain) {
        self.loadingManager = loadingManager
    }

    func downloadFailed(with error: any Error) {
        let retry = DMButtonAction { [weak self] in
            self?.download()
        }
        loadingManager.showFailure(error, provider: provider, onRetry: retry)
    }

    func download() {
        loadingManager.showLoading(provider: provider)
        // Start the work again here.
    }
}
```

The provider of a state decides its views: `DefaultDMLoadingViewProvider` draws the library's
views, and [Custom views](#custom-views) shows a provider of your own.

### Behaviour your app must know

While a HUD is shown, DMUnLoader hides the windows of its scene that are not above the HUD's window from assistive technology, and so from your own UI tests, until the HUD goes.

## Customization
### Custom views
Conform a class to `DMLoadingViewProvider` to replace the default loading, error, and success views:

```swift
import SwiftUI
import DMUnLoader

final class CustomDMLoadingViewProvider: DMLoadingViewProvider {
    @MainActor
    func getLoadingView() -> some View {
        Text("Custom Loading View")
            .padding()
            .background(Color.blue)
    }

    @MainActor
    func getErrorView(
        error: Error,
        onRetry: DMAction?,
        onClose: DMAction
    ) -> some View {
        VStack {
            Text("Custom Error View")
            if let onRetry = onRetry {
                Button("Retry", action: onRetry.simpleAction)
            }
            Button("Close", action: onClose.simpleAction)
        }
    }

    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
        Text("Custom Success View")
    }
}
```

### Settings
Override only the view settings you need; `DMLoadingViewProvider` supplies defaults for the rest. This provider changes the color of the success image:

```swift
import DMUnLoader
import SwiftUI

final class MintSuccessProvider: DMLoadingViewProvider {
    var successViewSettings: any DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(
            successImageProperties: SuccessImageProperties(foregroundColor: .mint)
        )
    }
}
```

The auto-hide delay belongs to the loading manager: a success or a failure hides after its `settings.autoHideDelay`, 2 seconds for the manager that `DMRootLoadingView` and `DMSceneDelegateTypeUIKit` create. A provider's `loadingManagerSettings` is not read; earlier versions of this README set the delay there, which never had an effect. To choose the delay, create the manager yourself and give it to `DMRootLoadingView(manager:content:)`, as in [SwiftUI with a manager your app owns](#swiftui-with-a-manager-your-app-owns):

```swift
import DMUnLoader

@MainActor
func makeLoadingManager() -> DMLoadingManagerMain {
    DMLoadingManagerMain(
        state: .none,
        settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(4))
    )
}
```

### Texts and languages
The default texts of the HUD, the failure title "An error has occurred!", "Close", "Retry" and "Loading...", come from the string catalog of DMUnLoader and follow the language of your app. In 1.1.0 the catalog holds English only, so every language shows these English texts. A text you set in the settings is shown as you wrote it. A text equal to an English default counts as that default, also when you pass it yourself, and follows the catalog.

---

## Example project
The [DMUnLoaderPodSPMExample](./Examples/DMUnLoaderPodSPMExample/) project demonstrates the SDK in SwiftUI and UIKit. It includes two schemes:

- **`Debug-SwiftUI`:** SwiftUI integration.
- **`Debug-UIKit`:** UIKit integration.

To run the example project:

1. Clone the repository.
2. Run `pod install`. CocoaPods is the default dependency manager. To select one explicitly, run either `DEPENDENCY_MANAGER=POD pod install` or `DEPENDENCY_MANAGER=SPM pod install`.
3. Open `DMUnLoaderPodSPMExample.xcworkspace` in Xcode.
4. Select the desired scheme and run the app.

---

## Implementation details
### Separate overlay window
DMUnLoader presents loading, error, and success views in a dedicated overlay window above the app's main interface. The approach was inspired by [Custom HUDs in SwiftUI](https://www.fivestars.blog/articles/swiftui-hud/) and [How to layer multiple windows in SwiftUI](https://www.fivestars.blog/articles/swiftui-windows/).

### Dependency-manager test project
The [DMUnLoaderPodSPMExample](#-example-project) project can resolve the SDK through either Swift Package Manager or CocoaPods. See [Using Swift Package Manager and CocoaPods with the same SDK](https://medium.com/@mykola.dementiev/how-to-seamlessly-use-swift-package-manager-spm-and-cocoapods-pod-together-with-the-same-sdk-1b80a2051c14) for the setup.

> This dual dependency-manager setup exists only in the example project. An application target should integrate DMUnLoader through either SPM or CocoaPods, not both.

### Test-driven development
Core views and the loading manager were developed through a test-driven workflow. Test plans and design notes are available in the [`DocumentationAndBluePrints`](./DocumentationAndBluePrints/) folder.

### Backdrop
While a HUD is shown, DMUnLoader draws a backdrop behind its card. The default, `.variableBlur`, is the backdrop of every release so far: the variable blur of [DMVariableBlurView](https://github.com/nikolay-dementiev/DMVariableBlurView) under a black dim. That blur uses a private API of the system; read the README of DMVariableBlurView before you ship it. `.dim()`, `.material()` and `.clear` draw with public API only. Under the system's Reduce Transparency the HUD draws neither the blur nor a material: `.variableBlur` keeps its dim, and `.material()` gives way to that dim.

```swift
import DMUnLoader

@MainActor
func makeDimmedLoadingManager() -> DMLoadingManagerMain {
    DMLoadingManagerMain(
        state: .none,
        settings: DMLoadingManagerDefaultSettings(backdrop: .dim())
    )
}
```

Choosing one of them only stops DMUnLoader from creating the variable blur while your app runs. DMUnLoader still depends on DMVariableBlurView, so its code, with the private names a scan of your binary finds, stays in your app. No setting of DMUnLoader 1.1.0 removes it.

### Retry and fallback
The SDK composes retry and fallback behavior with [DMAction](https://github.com/nikolay-dementiev/DMAction).

---

## Known issues
The default card of the HUD, white text on gray at opacity 0.8, does not reach the contrast of 4.5:1; an app that needs it sets its own colours through the settings types, or supplies its own views through `DMLoadingViewProvider`.

---

## Contributing
Contributions are welcome. Open an issue for a bug or feature request, or submit a pull request with a proposed change.

[CONTRIBUTING.md](./CONTRIBUTING.md) says how to build and test the package and the example app. The example's UI tests run one launch mode per process: a scene session that one integration mode leaves saved would otherwise be restored by the next launch, in another mode.

---

## Contact
For questions or feedback, contact me at [nikolas.dementiev@gmail.com](mailto:nikolas.dementiev@gmail.com).

---

## References
1. The separate-window approach was inspired by [Custom HUDs in SwiftUI](https://www.fivestars.blog/articles/swiftui-hud/) and [How to layer multiple windows in SwiftUI](https://www.fivestars.blog/articles/swiftui-windows/).
2. The example project's SPM/CocoaPods configuration is described in [Using Swift Package Manager and CocoaPods with the same SDK](https://medium.com/@mykola.dementiev/how-to-seamlessly-use-swift-package-manager-spm-and-cocoapods-pod-together-with-the-same-sdk-1b80a2051c14).

---

## License
DMUnLoader is available under the MIT License. See [LICENSE](LICENSE) for details.
