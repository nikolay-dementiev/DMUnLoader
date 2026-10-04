# DMUnLoader
**Universal Loader & Result Handler**

[![Build Status](https://app.bitrise.io/app/9e391394-db73-473f-998a-2026373de643/status.svg?token=mL8evw6RHiRtfKSiQ82zuw&branch=develop)](https://app.bitrise.io/app/9e391394-db73-473f-998a-2026373de643)
[![Swift](https://img.shields.io/badge/Swift-6.2%2B-orange)](https://swift.org)
[![Swift tools version](https://img.shields.io/badge/Swift_tools-6.2-darkorange)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/badge/platform-iOS_17%2B-blue)](https://developer.apple.com/ios)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-orange?style=flat-square)](#swift-package-manager)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DMUnLoader.svg?style=flat-square)](https://cocoapods.org/pods/DMUnLoader)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader.svg?type=small)](https://app.fossa.com/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader?ref=badge_small)

<p align="center">
  <img src="./DocumentationAndBluePrints/Assets/DMUnloade_mainImage.png?raw=true" alt="DMUnLoader SDK logo" style="max-height: 400px; aspect-ratio: 1536/1024; object-fit: scale-down;">
</p>

## Overview

`DMUnLoader` presents mutually exclusive loading, error, and success states in iOS applications. It is built with SwiftUI and works in both SwiftUI and UIKit apps.

### Key features

- **Dedicated overlay window:** Presents states above the app's main interface and blocks interaction with controls underneath. The window approach was inspired by:
    - [Custom HUDs in SwiftUI](https://www.fivestars.blog/articles/swiftui-hud/)
    - [How to layer multiple windows in SwiftUI](https://www.fivestars.blog/articles/swiftui-windows/)
- **Custom views:** The `DMLoadingViewProvider` protocol lets clients replace `DMErrorView`, `DMProgressView`, and `DMSuccessView`.
- **Configurable appearance and timing:** A view provider overrides texts, colors and layout and keeps the defaults for the rest. The loading manager's settings decide how long a success or a failure stays on screen.
- **Retry and fallback:** Composes retry and fallback behavior through `DMAction`. See the [DMAction article](https://medium.com/@mykola.dementiev/handling-actions-in-swift-using-retry-and-fallback-feature-fab138d35165) or the [DMAction GitHub repository](https://github.com/nikolay-dementiev/DMAction).
- **Dynamic blur:** Uses [`DMVariableBlurView`](https://github.com/nikolay-dementiev/DMVariableBlurView) to render the blur behind active states.

---

## Contents

- [Demo](#demo)
- [Architecture](#architecture)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
- [Usage](#usage)
  - [SwiftUI](#swiftui)
  - [SwiftUI with a manager your app owns](#swiftui-with-a-manager-your-app-owns)
  - [UIKit](#uikit)
  - [Behaviour your app must know](#behaviour-your-app-must-know)
- [Customization](#customization)
  - [Custom views](#custom-views)
  - [Settings](#settings)
  - [Texts and languages](#texts-and-languages)
- [Example project](#example-project)
- [Implementation details](#implementation-details)
  - [Separate overlay window](#separate-overlay-window)
  - [Dependency-manager test project](#dependency-manager-test-project)
  - [Test-driven development](#test-driven-development)
  - [Backdrop](#backdrop)
  - [Retry and fallback](#retry-and-fallback)
- [Known issues](#known-issues)
- [Contributing](#contributing)
- [Contact](#contact)
- [References](#references)
- [License](#license)

---

## Demo

The examples below show the default views on the left and customized views on the right.

- **Loading state:**
<p align="left">
  <img src="./DocumentationAndBluePrints/Assets/TestProject-ScreenRecording/Loadiing-Default+Custom-Recording.gif?raw=true" alt="Loading state demo" style="max-height: 500px; aspect-ratio: 640/694; object-fit: scale-down;">
</p>

- **Success state:**
<p align="left">
  <img src="./DocumentationAndBluePrints/Assets/TestProject-ScreenRecording/Success-Default+Custom-Recording.gif?raw=true" alt="Success state demo" style="max-height: 500px; aspect-ratio: 640/694; object-fit: scale-down;">
</p>

- **Error state:**
<p align="left">
  <img src="./DocumentationAndBluePrints/Assets/TestProject-ScreenRecording/Error-Default+Custom-Recording.gif?raw=true" alt="Error state demo" style="max-height: 500px; aspect-ratio: 640/694; object-fit: scale-down;">
</p>

---

## Architecture
> Click the image to open it at full size.
<p align="center">
  <a href="./DocumentationAndBluePrints/Assets/plantumUML-base APP+SDK schema.svg?raw=true" target="_blank">
    <img src="./DocumentationAndBluePrints/Assets/plantumUML-base APP+SDK schema.svg?raw=true" alt="High-Level Architecture" style="max-height: 800px; aspect-ratio: 3012 / 1870; object-fit: scale-down;">
  </a>
</p>

---

## Installation

DMUnLoader needs a Swift 6.2 compiler, which Xcode 26.0 and later include, and runs on
iOS 17 and later.

### Swift Package Manager

To integrate **DMUnLoader** using **Swift Package Manager**, add the following dependency to your `Package.swift`:

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

### CocoaPods
To integrate `DMUnLoader` with CocoaPods, add the following dependency to your `Podfile`:

```ruby
pod 'DMUnLoader', '~> 1.0.3'
```

---

## Usage
### SwiftUI

`DMRootLoadingView` creates the loading manager and passes it to your root content view. The same manager presents loading, success, and failure states.

```swift
import SwiftUI
import DMUnLoader

@main
struct ExampleApp: App {
    @UIApplicationDelegateAdaptor private var delegate: DMAppDelegateType

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView { loadingManager in
                ContentView(
                    loadingManager: loadingManager,
                    provider: DefaultDMLoadingViewProvider()
                )
            }
        }
    }
}

struct ContentView<
    LM: DMLoadingManager,
    Provider: DMLoadingViewProvider
>: View {
    let loadingManager: LM
    let provider: Provider

    var body: some View {
        VStack {
            Button("Show loading") {
                loadingManager.showLoading(provider: provider)
            }

            Button("Show success") {
                loadingManager.showSuccess("Data successfully loaded!", provider: provider)
            }
        }
    }
}
```

`DMRootLoadingView { ... }` needs the app delegate: `DMAppDelegateType`, or `DMAppDelegate<YourManager>` for a manager type of your own, puts the scene delegate of DMUnLoader into the environment. Without it SwiftUI stops the app when the view appears.

### SwiftUI with a manager your app owns

`DMRootLoadingView(manager:content:)` needs no app delegate of DMUnLoader. It shows the HUD of the manager you give it over the scene of the window the view is in.

```swift
import DMUnLoader
import SwiftUI

@main
struct ExampleApp: App {
    @StateObject private var loadingManager = DMLoadingManagerMain(
        state: .none,
        settings: DMLoadingManagerDefaultSettings()
    )

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView(manager: loadingManager) { loadingManager in
                Button("Show loading") {
                    loadingManager.showLoading(provider: DefaultDMLoadingViewProvider())
                }
            }
        }
    }
}
```

Keep the manager alive outside the view, as the `@StateObject` above does, and use one such view per scene: the HUD of each view joins the scene of that view. CI does not test multi-window on iPad; a local run on an iPad simulator does, before a release.

### UIKit

UIKit integration installs `DMSceneDelegateTypeUIKit` as the scene delegate. `DMSceneDelegateHelper` supplies the root view controller and receives the loading manager.

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

> API compatibility note: the requirement keeps its released name, `makeUIKitRootViewHierarhy`, until 2.0.0. DMUnLoader calls it on the main actor, so make the helper a `@MainActor` type that conforms with `@MainActor DMSceneDelegateHelper`, as above: in Swift 6 mode a plain conformance stops with "sending 'loadingManager' risks causing data races". Such a conformance needs the Swift 6.2 compiler (Xcode 26), which DMUnLoader requires.

### Behaviour your app must know

While a HUD is shown, DMUnLoader hides the windows of its scene that are not above the HUD's window from assistive technology, and so from your own UI tests, until the HUD goes.

---

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
