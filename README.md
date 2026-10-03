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
- **Configurable appearance:** Override text, color, layout, and auto-hide settings while retaining defaults for everything else.
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
- [Customization](#customization)
  - [Custom views](#custom-views)
  - [Settings](#settings)
- [Example project](#example-project)
- [Implementation details](#implementation-details)
  - [Separate overlay window](#separate-overlay-window)
  - [Dependency-manager test project](#dependency-manager-test-project)
  - [Test-driven development](#test-driven-development)
  - [Backdrop](#backdrop)
  - [Retry and fallback](#retry-and-fallback)
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
dependencies: [
    .package(url: "https://github.com/nikolay-dementiev/DMUnLoader.git", from: "1.0.3")
]
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
@main
struct ExampleApp: App {
    @StateObject private var loadingManager = DMLoadingManagerMain(
        state: .none,
        settings: DMLoadingManagerDefaultSettings()
    )

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView(manager: loadingManager) { loadingManager in
                ContentView(
                    loadingManager: loadingManager,
                    provider: DefaultDMLoadingViewProvider()
                )
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

struct AppDelegateHelper {}

extension AppDelegateHelper: DMSceneDelegateHelper {
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

> API compatibility note: released versions currently expose `makeUIKitRootViewHierarhy`. The example keeps that spelling so it matches the public protocol. A source-compatible migration should add `makeUIKitRootViewHierarchy` and deprecate the old name before the documentation switches to the corrected API.

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
Override only the settings you need; `DMLoadingViewProvider` supplies defaults for the rest. This example changes the auto-hide delay and success icon color:

```swift
extension CustomDMLoadingViewProvider {
    var loadingManagerSettings: DMLoadingManagerSettings {
        CustomLoadingManagerSettings()
    }

    private struct CustomLoadingManagerSettings: DMLoadingManagerSettings {
        var autoHideDelay: Duration = .seconds(4)
    }

    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(
            successImageProperties: SuccessImageProperties(
                foregroundColor: .green
            )
        )
    }
}

let provider = CustomDMLoadingViewProvider()
loadingManager.showSuccess(
    "Data successfully loaded!",
    provider: provider
)
```

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
While a HUD is shown, DMUnLoader draws a backdrop behind its card. The default, `.variableBlur`, is the backdrop of every release so far: the variable blur of [DMVariableBlurView](https://github.com/nikolay-dementiev/DMVariableBlurView) under a black dim. That blur uses a private API of the system; read the README of DMVariableBlurView before you ship it. `.dim()`, `.material()` and `.clear` draw with public API only.

```swift
let loadingManager = DMLoadingManagerMain(
    state: .none,
    settings: DMLoadingManagerDefaultSettings(backdrop: .dim())
)
```

Choosing one of them only stops DMUnLoader from creating the variable blur while your app runs. DMUnLoader still depends on DMVariableBlurView, so its code, with the private names a scan of your binary finds, stays in your app. No setting of DMUnLoader 1.1.0 removes it.

### Retry and fallback
The SDK composes retry and fallback behavior with [DMAction](https://github.com/nikolay-dementiev/DMAction).

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
