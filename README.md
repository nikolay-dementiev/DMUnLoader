# DMUnLoader 
#### Universal Loader & Result Handler

[![Build Status](https://app.bitrise.io/app/9e391394-db73-473f-998a-2026373de643/status.svg?token=mL8evw6RHiRtfKSiQ82zuw&branch=develop)](https://app.bitrise.io/app/9e391394-db73-473f-998a-2026373de643)
[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS-blue)](https://developer.apple.com/ios)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://swift.org/package-manager)
[![CocoaPods Compatible](https://img.shields.io/badge/CocoaPods-compatible-brightgreen)](https://cocoapods.org)

## Overview

The SDK simplifies the integration of common dialog states (`Error`, `Loading`, `Success`) in iOS applications. Only one state can be displayed at a time, ensuring a sequential and consistent behavior. 
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

1. [Installation](#installation)
   - [Swift Package Manager](#swift-package-manager)
   - [CocoaPods](#cocoapods)
2. [Usage](#usage)
   - [SwiftUI Integration](#swiftui-integration)
   - [UIKit Integration](#uikit-integration)
3. [Customization](#customization)
   - [Custom Views](#custom-views)
   - [Settings Configuration](#settings-configuration)
4. [Example Project](#example-project)
5. [Advanced Features](#advanced-features)
   - [Retry and Fallback Actions](#retry-and-fallback-actions)
   - [Dynamic Blur Effects](#dynamic-blur-effects)
6. [Future Enhancements](#future-enhancements)

---

## Installation

### Swift Package Manager

To integrate **DMUnLoader** using **Swift Package Manager**, add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nikolay-dementiev/DMUnLoader.git", from: "1.0.0")
]
```

### CocoaPods
To integrate `DMUnLoader` using `CocoaPods`, add the following line to your Podfile:

```ruby
pod 'DMUnLoader', :git => 'https://github.com/nikolay-dementiev/DMUnLoader.git'
```

---

Test project named as `DMUnLoaderPodSPMExample` (`../Examples/DMUnLoaderPodSPMExample/DMUnLoaderPodSPMExample.*`) uses a method for simultaneous use of the library by different dependency managers. For more details on managing dependencies with both `SPM` and `CocoaPods`, refer to [this article](https://medium.com/@mykola.dementiev/how-to-seamlessly-use-swift-package-manager-spm-and-cocoapods-pod-together-with-the-same-sdk-1b80a2051c14?spm=a2ty_o01.29997173.0.0.31de5171JtCMAz).


---

## Usage
### SwiftUI Integration

Here is an pseudocode example of how to use **DMUnLoader** in a **SwiftUI** project *(for real code example, please check the **DMUnLoaderPodSPMExample** project)*:

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
            Button("Simulate Loading", action: viewModel.showDownloads)
                .buttonStyle(.dmBorderedCorner)
            Button("Simulate Error", action: viewModel.simulateAnError)
                .buttonStyle(.dmBorderedCorner)
            Button("Simulate Success", action: viewModel.simulateSuccess)
                .buttonStyle(.dmBorderedCorner)
        }
    }
}
```

### UIKit Integration
For **UIKit** projects, here is an pseudocode example of how to use **DMUnLoader** *(for real code example, please check the **DMUnLoaderPodSPMExample** project)*:

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
        
        let tabViewController = MainTabViewControllerUIKit(
            loadingManager: loadingManager
        )
        
        return tabViewController
    }
}

final class DefaultSettingsViewController<LM: DMLoadingManager>: UIViewController {
    private(set) weak var loadingManager: LM?
    
    init(loadingManager: LM?) {
        self.loadingManager = loadingManager
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        
        let newCustedView =  LoadingContentViewUIKit()
        newCustedView.configure(
            loadingManager: loadingManager,
            provider: DefaultDMLoadingViewProvider() // OR CustomDMLoadingViewProvider() --> need to be implemented by the client! See `DMUnLoaderPodSPMExample` for details
        )
        
        view = newCustedView
        view.setNeedsUpdateConstraints()
    }
}

import Combine

final class LoadingContentViewUIKit<
    Provider: DMLoadingViewProvider,
    LM: DMLoadingManager
>: UIView {
    private var loadingManager: LM?
    private var provider: Provider?
    
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func configure(loadingManager: LM?, provider: Provider?) {
        self.loadingManager = loadingManager
        self.provider = provider
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Container settings
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


## Customization
### Custom Views
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

    // and also some properties:

    var loadingManagerSettings: DMLoadingManagerSettings { CustomLoadingManagerSettings() }
    
    private struct CustomLoadingManagerSettings: DMLoadingManagerSettings {
        var autoHideDelay: Duration = .seconds(4)
    }
    
    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(successImageProperties: SuccessImageProperties(foregroundColor: mainColor.opacity(0.7)))
    }
}
```

### Settings Configuration
The SDK allows you to customize the appearance of the built-in views by configuring settings such as text properties, colors, and layout. All these settings will be picked up by using `Provider` object. Only interested to you settings can be overridden - the rest will be used as default ones (because `DMLoadingViewProvider` protocol has default implementation on SDK side). Here's an example:

```Swift
struct CustomDMLoadingViewProvider: DMLoadingViewProvider {
    var loadingManagerSettings: DMLoadingManagerSettings { CustomLoadingManagerSettings() }
    
    private struct CustomLoadingManagerSettings: DMLoadingManagerSettings {
        var autoHideDelay: Duration = .seconds(4)
    }
    
    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(successImageProperties: SuccessImageProperties(foregroundColor: mainColor.opacity(0.7)))
    }
}

let provider = CustomDMLoadingViewProvider()
loadingManager.showSuccess("Data successfully loaded!",
                            provider: provider)
```