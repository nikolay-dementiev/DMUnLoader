# DMUnLoader 
#### Universal Loader & Result Handler

[![Build Status](https://app.bitrise.io/app/9e391394-db73-473f-998a-2026373de643/status.svg?token=mL8evw6RHiRtfKSiQ82zuw&branch=develop)](https://app.bitrise.io/app/9e391394-db73-473f-998a-2026373de643)
[![Swift Version](https://img.shields.io/badge/Swift-5-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS-blue)](https://developer.apple.com/ios)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DMUnLoader.svg?style=flat-square)](https://img.shields.io/cocoapods/v/DMUnLoader.svg)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader.svg?type=small)](https://app.fossa.com/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader?ref=badge_small)

<p align="center">
  <img src="./DocumentationAndBluePrints/Assets/DMUnloade_mainImage.png?raw=true" alt="DMAction-SDK-logo" style="max-height: 400px; aspect-ratio: 1536/1024; object-fit: scale-dow;">
</p>

## Overview

The `SDK` simplifies the integration of common dialog states (`Error`, `Loading`, `Success`) in iOS applications. Only one state can be displayed at a time, ensuring a sequential and consistent behavior. 
Built with **SwiftUI**, it supports both **UIKit** and **SwiftUI** environments, making it suitable for modern app development.

### Key features include:
- **Separate System Window:** Dialogs are displayed in a dedicated system window, ensuring they overlay the entire app interface without leaving interactive elements (e.g., Tab Bars) active. Inspired by [fivestars.blog](www.fivestars.blog): 
    - [SwiftUI HUD](https://www.fivestars.blog/articles/swiftui-hud/) 
    - [SwiftUI Windows](https://www.fivestars.blog/articles/swiftui-windows/)
- **Customizable Views:** Replace default views (`DMErrorView`, `DMProgressView`, `DMSuccessView`) with custom implementations via the `DMLoadingViewProvider` protocol (**by using `dependency invertion` pronciple**).
- **Settings Configuration:** Fine-tune the appearance of built-in views using settings like text properties, colors, and layout.
- **Retry & Fallback Logic:** Incorporates robust action handling using retry and fallback mechanisms. For more information, refer to [DMAction documentation](https://medium.com/@mykola.dementiev/handling-actions-in-swift-using-retry-and-fallback-feature-fab138d35165) or [DMAction github page](https://github.com/nikolay-dementiev/DMAction).
- **Dynamic Blur Effects:** Integrates with the [`DMVariableBlurView`](https://github.com/nikolay-dementiev/DMVariableBlurView) library to apply dynamic blur effects.

---

## Table of Contents

- [🎬 Demo: Loading, Success & Error States](#-demo-loading-success--error-states)
- [🧭 Very High-Level Architecture in Picture](#-very-high-level-architecture-in-picture)
- [📥 Installation](#-installation)
   - [📦 Swift Package Manager](#-swift-package-manager)
   - [🍫 CocoaPods](#-cocoapods)
- [🛠 Usage](#-usage)
   - [![](./DocumentationAndBluePrints/Assets/icons8-swiftui-16.png) SwiftUI Integration](#-swiftui-integration)
   - [![](./DocumentationAndBluePrints/Assets/icons8-uikit-16.png) UIKit Integration](#-uikit-integration)
- [🎨 Customization](#-customization)
   - [🖌 Custom Views](#-custom-views)
   - [⚙ Settings Configuration](#-settings-configuration)
- [🧪 Example Project](#-example-project)
- [🚀 Advanced Features](#-advanced-features)
   - [🔁 Retry and Fallback Actions](#-retry-and-fallback-actions)
   - [🌫 Dynamic Blur Effects](#-dynamic-blur-effects)
- [🧩 Implementation Details](#-implementation-details)
    1. [🪟 Separate System Window](#-1-separate-system-window)
    2. [📦🍫 Dual Dependency Manager Usage in Test Project](#-2-dual-dependency-manager-usage-in-test-project)
    3. [🎯 TDD Approach](#-3-tdd-approach)
    4. [🌫 Custom Blur Effects](#-4-custom-blur-effects)
    5. [🔁 Retry and Fallback Actions](#-5-retry-and-fallback-actions)
- [🚧 Future Enhancements](#-future-enhancements)
- [🙏 Acknowledgments](#-acknowledgments)
- [📜 License](#-license)

---

## 🎬 Demo: Loading, Success & Error States
<!-- was made within: https://ezgif.com/combine/ and https://ezgif.com/video-to-gif) -->

Watch how `DMUnLoader` behaves in different states with `default` (left) and `custom` (right) settings:

- **Loading State**:  
<p align="left">
  <img src="./DocumentationAndBluePrints/Assets/TestProject-ScreenRecording/Loadiing-Default+Custom-Recording.gif?raw=true" alt="Loading Demo" style="max-height: 500px; aspect-ratio: 640/694; object-fit: scale-dow;">
</p>

- **Success State**:  
<p align="left">
  <img src="./DocumentationAndBluePrints/Assets/TestProject-ScreenRecording/Success-Default+Custom-Recording.gif?raw=true" alt="Success Demo" style="max-height: 500px; aspect-ratio: 640/694; object-fit: scale-dow;">
</p>

- **Error State**:  
<p align="left">
  <img src="./DocumentationAndBluePrints/Assets/TestProject-ScreenRecording/Error-Default+Custom-Recording.gif?raw=true" alt="Error Demo" style="max-height: 500px; aspect-ratio: 640/694; object-fit: scale-dow;">
</p>

---

### 🧭 Very High-Level Architecture in Picture
> click on the image to view it in full screen mode
<p align="center">
  <a href="./DocumentationAndBluePrints/Assets/plantumUML-base APP+SDK schema.svg?raw=true" target="_blank">
    <img src="./DocumentationAndBluePrints/Assets/plantumUML-base APP+SDK schema.svg?raw=true" alt="High-Level Architecture" style="max-height: 800px; aspect-ratio: 3012 / 1870; object-fit: scale-down;">
  </a>
</p>

---

## 📥 Installation

### 📦 Swift Package Manager

To integrate **DMUnLoader** using **Swift Package Manager**, add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nikolay-dementiev/DMUnLoader.git", from: "1.0.0")
]
```

### 🍫 CocoaPods
To integrate `DMUnLoader` using `CocoaPods`, add the following line to your Podfile:

```ruby
pod 'DMUnLoader', :git => 'https://github.com/nikolay-dementiev/DMUnLoader.git'
```

---

## 🛠 Usage
### ![](./DocumentationAndBluePrints/Assets/icons8-swiftui-24.png) SwiftUI Integration

Here is an pseudocode example of how to use **DMUnLoader** in a **SwiftUI** project *(for real code example, please check the **[Example Project](#-example-project)**)*:

```Swift
import SwiftUI
import DMUnLoader

@main
struct DMUnLoaderPodSPMExampleApp: App {
    @UIApplicationDelegateAdaptor private var delegate: DMAppDelegateType
    
    var body: some Scene {
        WindowGroup {
            DMRootLoadingView { loadingManager in // DMRootLoadingView - handles `sceneDelegate` by itself
                LoadingContentViewSwiftUI(
                    loadingManager: loadingManager,
                    provider: DefaultDMLoadingViewProvider() // OR CustomDMLoadingViewProvider() --> need to be implemented by the client! See `DMUnLoaderPodSPMExample` for details
                )
            }
        }
    }
}


struct LoadingContentViewSwiftUI<Provider: DMLoadingViewProvider,
                                 LM: DMLoadingManager>: View {
    var loadingManager: LM
    var provider: Provider
    
    var body: some View {
        VStack {
            Button("Simulate Loading", action: showDownloads)
                .buttonStyle(.dmBorderedCorner)
            Button("Simulate Error", action: simulateAnError)
                .buttonStyle(.dmBorderedCorner)
            Button("Simulate Success", action: simulateSuccess)
                .buttonStyle(.dmBorderedCorner)
        }
    }
}
```

### ![](./DocumentationAndBluePrints/Assets/icons8-uikit-24.png) UIKit Integration
For **UIKit** projects, here is an pseudocode example of how to use **DMUnLoader** *(for real code example, please check the **[Example Project](#-example-project)**)*:

```swift 
import UIKit
import DMUnLoader

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let configuration = UISceneConfiguration(name: "Default Configuration",
                                                 sessionRole: connectingSceneSession.role)

        configuration.delegateClass = DMSceneDelegateTypeUIKit<AppDelegateHelper>.self
        
        return configuration
    }
}

extension AppDelegateHelper: DMSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(loadingManager: LM) -> UIViewController {
         DefaultSettingsViewController(
            loadingManager: loadingManager
        )
    }
}

final class DefaultSettingsViewController<LM: DMLoadingManager>: UIViewController {
    private(set) weak var loadingManager: LM?
    
    init(loadingManager: LM?) {
        self.loadingManager = loadingManager
        ...
    }
    
    override func loadView() {
        ...
        let newCustedView =  LoadingContentViewUIKit()
        newCustedView.configure(
            loadingManager: loadingManager,
            provider: DefaultDMLoadingViewProvider() // OR CustomDMLoadingViewProvider() --> need to be implemented by the client! See `DMUnLoaderPodSPMExample` for details
        )
        
        view = newCustedView
        ...
    }
}

final class LoadingContentViewUIKit<
    Provider: DMLoadingViewProvider,
    LM: DMLoadingManager
>: UIView {
    private var loadingManager: LM?
    private var provider: Provider?
    
    private let stackView = UIStackView()

    ...
    
    func configure(loadingManager: LM?, provider: Provider?) {
        self.loadingManager = loadingManager
        self.provider = provider
    }
    
    private func setupUI() {
        ....
        addSubview(stackView)
        
        // Buttons
        let buttonShowDownloads = UIButton(type: .system)
        buttonShowDownloads.addTarget(self, action: #selector(showDownloads), for: .touchUpInside)
        stackView.addArrangedSubview(buttonShowDownloads)

        let buttonSimulateAnError = UIButton(type: .system)
        buttonSimulateAnError.addTarget(self, action: #selector(buttonSimulateAnError), for: .touchUpInside)
        stackView.addArrangedSubview(buttonSimulateAnError)

        let buttonSimulateSuccess = UIButton(type: .system)
        buttonSimulateSuccess.addTarget(self, action: #selector(buttonSimulateSuccess), for: .touchUpInside)
        stackView.addArrangedSubview(buttonSimulateSuccess)
        ...
    }
    
    @objc func showDownloads() {
        loadingManager?.showSuccess("Data successfully loaded!",
                                    provider: provider)
    }

    @objc func simulateAnError() {
        let error = DMAppError.custom("Some test Error occured!")
        loadingManager?.showFailure(error,
                                    provider: provider,
                                    onRetry: DMButtonAction { [weak self] completion in
            ....
        }
            .retry(2)
            .fallbackTo(DMButtonAction(...)))
    }

    @objc func simulateSuccess() {
        loadingManager?.showSuccess("Data successfully loaded!",
                                    provider: provider)
    }
}
```

---

## 🎨 Customization
### 🖌 Custom Views
You can replace the default views (**DMErrorView**, **DMProgressView**, **DMSuccessView**) with your own custom views by conforming to the **DMLoadingViewProvider** protocol. Here's an example:

```Swift
struct CustomDMLoadingViewProvider: DMLoadingViewProvider {
    func getLoadingView() -> some View {
        Text("Custom Loading View")
            .padding()
            .background(Color.blue)
    }

    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> some View {
        VStack {
            Text("Custom Error View")
            if let onRetry = onRetry {
                Button("Retry", action: onRetry.simpleAction)
            }
            Button("Close this", action: onClose.simpleAction)
        }
    }

    func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
        Text("Custom Success View")
    }
    ...
}
```

## ⚙ Settings Configuration
The SDK allows you to customize the appearance of the built-in views by configuring settings such as text properties, colors, and layout. All these settings will be picked up by using `Provider` object. Only interested to you settings can be overridden - the rest will be used as default ones (because `DMLoadingViewProvider` protocol has default implementation on SDK side). Here's an example:

```Swift
struct CustomDMLoadingViewProvider: DMLoadingViewProvider {
    ...

    var loadingManagerSettings: DMLoadingManagerSettings { CustomLoadingManagerSettings() }
    
    private struct CustomLoadingManagerSettings: DMLoadingManagerSettings {
        var autoHideDelay: Duration = .seconds(4)
    }
    
    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(successImageProperties: SuccessImageProperties(foregroundColor: .green))
    }
}

let provider = CustomDMLoadingViewProvider()
loadingManager.showSuccess("Data successfully loaded!",
                            provider: provider)
```

---

## 🧪 Example Project
The **DMUnLoaderPodSPMExample** project <a href="./Examples/DMUnLoaderPodSPMExample/DMUnLoaderPodSPMExample.xcworkspace" target="_blank">(./Examples/DMUnLoaderPodSPMExample/DMUnLoaderPodSPMExample.xcworkspace)</a> demonstrates how to use the `SDK` in both **SwiftUI** and **UIKit** environments. It includes two schemes:

- **`Debug-SwiftUI`**: Demonstrates integration with `SwiftUI`.
- **`Debug-UIKit`**: Demonstrates integration with `UIKit`.

To run the example project:

1. Clone the repository.
2. run `pod install`; select the appropriate Depenency manager (`POD` or `SMP`) if neded; `POD` will be used by default (the commad like: `DEPENDENCY_MANAGER=POD pod install`)
3. Open `DMUnLoaderPodSPMExample.xcworkspace` in Xcode.
4. Select the desired scheme and run the app.

---

## 🧩 Implementation Details
### 🪟 1. Separate System Window
All dialogs (**Error**, **Loading**, **Success**) are displayed in a separate system window, ensuring they overlay the entire app interface without leaving interactive elements (e.g., `Tab Bars`) active. This approach is inspired by [SwiftUI HUD](https://www.fivestars.blog/articles/swiftui-hud/?spm=a2ty_o01.29997173.0.0.31de5171XJJ06d) HUD and [SwiftUI Windows](https://www.fivestars.blog/articles/swiftui-windows/?spm=a2ty_o01.29997173.0.0.31de5171XJJ06d).

### 📦🍫 2. Dual Dependency Manager Usage in Test Project
The [DMUnLoaderPodSPMExample](#-example-project) test project demonstrates how to use the `SDK` with both **Swift Package Manager** (SPM) and **CocoaPods** simultaneously. This ensures seamless integration of the `SDK` regardless of the dependency manager used. For more details, refer to [this article](https://medium.com/@mykola.dementiev/how-to-seamlessly-use-swift-package-manager-spm-and-cocoapods-pod-together-with-the-same-sdk-1b80a2051c14?spm=a2ty_o01.29997173.0.0.31de5171XJJ06d).

>Important Note: This dual dependency manager setup is specific to this [DMUnLoaderPodSPMExample](#-example-project) test project and is not intended for production use. The main `SDK` itself supports installation via either SPM or CocoaPods, but not both simultaneously in a single target.

### 🎯 3. TDD Approach
Huge parts of the `SDK` were rewritten using a Test-Driven Development (BDD/TDD) approach to ensure robustness and reliability. The suporting documnents can be found in `DocumentationAndBluePrints` folder.

### 🌫 4. Custom Blur Effects
The `SDK` leverages the [**DMVariableBlurView**](https://github.com/nikolay-dementiev/DMVariableBlurView) library to apply dynamic blur effects to views.

### 🔁 5. Retry and Fallback Actions
The SDK supports retry and fallback mechanisms for handling failed actions. For more information, see the [**DMAction** GitHub page](https://github.com/nikolay-dementiev/DMAction).

---

## 🚧 Future Enhancements
The following features are planned for future releases:

- **Accessibility IDs** for views.
- Support for **Dark/Light themes**.
- **Localization** for text on views.
- **Analytics** integration to track events within the SDK.
- Enhanced **loggin** capabilities for error reporting.

---

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request or open an issue for any bugs or feature requests.

---

## 📬 Contact
For questions or feedback, feel free to contact me via [@-mail](nikolas.dementiev@gmail.com).

---

### 🙏 Acknowledgments
1. Inspiration for the separate window approach:[SwiftUI HUD](https://www.fivestars.blog/articles/swiftui-hud/?spm=a2ty_o01.29997173.0.0.31de5171XJJ06d) and [SwiftUI Windows](https://www.fivestars.blog/articles/swiftui-windows/?spm=a2ty_o01.29997173.0.0.31de5171XJJ06d)
2. Managing dependencies with both `SPM` and `CocoaPods` dependency manager: [this article](https://medium.com/@mykola.dementiev/how-to-seamlessly-use-swift-package-manager-spm-and-cocoapods-pod-together-with-the-same-sdk-1b80a2051c14?spm=a2ty_o01.29997173.0.0.31de5171JtCMAz)
3. Retry and Fallback Logic: [**DMAction** GitHub page](https://github.com/nikolay-dementiev/DMAction)
4. Dynamic Blur Effects: [**DMVariableBlurView** GitHub page](https://github.com/nikolay-dementiev/DMVariableBlurView)

---

## 📜 License
This project is licensed under the MIT License - see the LICENSE file for details.

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader.svg?type=large&issueType=license)](https://app.fossa.com/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader?ref=badge_large&issueType=license)
