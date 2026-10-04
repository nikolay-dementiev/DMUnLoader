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
`DMSceneDelegateHelper` supplies the root view controller and receives the loading manager. The
app declares a scene manifest, `UIApplicationSceneManifest` in its Info.plist: without one, UIKit
does not ask the app delegate for a scene configuration.

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

Retry runs your action and leaves the HUD as it is, so the action shows the next state itself.
By default a failure with Retry also hides by itself after 2 seconds and on any tap;
[The loading manager's settings](#the-loading-managers-settings) shows how to keep it until the
user acts.

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

## Configuration

### The loading manager's settings

`DMLoadingManagerDefaultSettings` holds the settings of a `DMLoadingManagerMain`. Each one
defaults to the behaviour of every release before 1.1.0:

- `autoHideDelay`: how long a success or a failure stays. 2 seconds.
- `hudDismissal`: how each kind leaves the screen, by itself or by a tap on its card or outside
  it, for a success, a failure without Retry and a failure with Retry. By default each hides
  after `autoHideDelay` and on any tap. The loading HUD stays until the next state, and taps do
  nothing.
- `hudWindowLevel`: the level of the HUD window. `.normal`.
- `backdrop`: what the HUD draws behind its card. `.variableBlur`; see [Backdrop](#backdrop).

```swift
import DMUnLoader

@MainActor
func makeLoadingManager() -> DMLoadingManagerMain {
    DMLoadingManagerMain(
        state: .none,
        settings: DMLoadingManagerDefaultSettings(
            autoHideDelay: .seconds(4),
            hudDismissal: DMHUDDismissalRules(
                failureWithRetry: DMHUDDismissal(autoHide: .never, cardTapHides: false)
            ),
            backdrop: .dim()
        )
    )
}
```

Here a failure with Retry waits for the user: it leaves through Close, a tap outside its card,
or another state. Give such a manager to `DMRootLoadingView(manager:content:)`. The settings of
a view provider do not change the manager: its `loadingManagerSettings` is not read. The README of
1.0.x set the delay there, which never had an effect.

### Backdrop

While a HUD is shown, DMUnLoader draws a backdrop behind its card. The default, `.variableBlur`,
is the backdrop of every release so far: the variable blur of
[DMVariableBlurView](https://github.com/nikolay-dementiev/DMVariableBlurView) under a black dim.
That blur uses a private API of the system; read the README of DMVariableBlurView before you ship
it. Where the system does not offer that API, DMVariableBlurView draws the plain blur of the system
over the whole screen instead and logs the reason under its own subsystem. `.dim()`, `.material()`
and `.clear` draw with public API only. Under the system's Reduce
Transparency the HUD draws neither the blur nor a material: `.variableBlur` keeps its dim,
`.material()` gives way to that dim, and the card of the HUD is opaque.

Choosing another backdrop only stops DMUnLoader from creating the variable blur while your app
runs. DMUnLoader still depends on DMVariableBlurView, so its code, with the private names a scan
of your binary finds, stays in your app. No setting of DMUnLoader 1.1.0 removes it.

### Custom views

Conform a class to `DMLoadingViewProvider` to replace the views of the states. Every requirement
has a default, the library's view, so implement only what you change:

```swift
import DMUnLoader
import SwiftUI

final class BrandedViewProvider: DMLoadingViewProvider {
    @MainActor
    func getLoadingView() -> some View {
        ProgressView("Please wait")
            .padding()
            .background(Color.white)
    }

    @MainActor
    func getErrorView(error: any Error, onRetry: (any DMAction)?, onClose: any DMAction) -> some View {
        VStack {
            Text(error.localizedDescription)
            if let onRetry {
                Button("Try again", action: onRetry.simpleAction)
            }
            Button("Close", action: onClose.simpleAction)
        }
        .padding()
        .background(Color.white)
    }
}
```

### View settings

A provider can keep the library's views and change their settings: texts, colours, images and
layout. This one only changes the colour of the success image:

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

`loadingViewSettings`, `errorViewSettings` and `successViewSettings` take
`DMProgressViewDefaultSettings`, `DMErrorDefaultViewSettings` and `DMSuccessDefaultViewSettings`,
or a type of your own that conforms to their protocol.

### Texts and languages

The default texts of the HUD, the failure title "An error has occurred!", "Close", "Retry" and
"Loading...", come from the string catalog of DMUnLoader and follow the language of your app. In
1.1.0 the catalog holds English only, so every language shows these English texts. A text you set
in the settings is shown as you wrote it. A text equal to an English default counts as that
default, also when you pass it yourself, and follows the catalog.

## Behaviour your app must know

### Touches

While a HUD is shown, its window takes every touch that reaches it: the windows of your app under
it receive none, whatever the backdrop. A tap on the card or outside it hides a success or a
failure as the dismissal rules say. Close hides a failure, and Retry runs your action. With no HUD
shown, every touch reaches your app.

### Threads and lifetime

The loading managers, the view providers and the root view work on the main actor: call them
there. Keep the manager alive: in a `@StateObject` of your app, or the one that the scene delegate
creates. The HUD keeps no replaced manager alive. Use one integration per scene: a scene whose
scene delegate of DMUnLoader holds a manager and that also shows
`DMRootLoadingView(manager:content:)` gets two HUD windows.

### Failures

`DMRootLoadingView(content:)` without the app delegate of DMUnLoader stops the app when the view
appears. `DMRootLoadingView(manager:content:)` needs no app delegate: until the view is in a
window of a scene, the manager waits, and the HUD appears once the view is in one.

### Accessibility

While a HUD is shown, DMUnLoader hides from assistive technology, and so from your own UI tests,
the windows of its scene at the HUD window's level or below that are open when the HUD appears,
until the HUD goes. When the HUD appears or shows another state, VoiceOver is told that the
screen changed and starts at its first element: the HUD's, unless a window above the HUD has
elements. When the HUD goes, VoiceOver returns to the element it was on, if that element is still
on the screen. The escape gesture hides a success or a failure as a tap outside the card does.
Reduce Motion keeps the card and a pressed button still. VoiceOver does not read the default
images; an image you supply keeps the accessibility you give it.

A success or a failure hides after 2 seconds by default, which can be too short to reach Retry
with VoiceOver or Switch Control. An app whose users need more time keeps a failure on the screen
with `DMHUDDismissal(autoHide: .never)`, or gives it a longer delay; see
[The loading manager's settings](#the-loading-managers-settings).

## Example app and tests

`Examples/DMUnLoaderExample` is an app that shows each state. Open
`DMUnLoaderExample.xcodeproj` and run one of its schemes: `DMUnLoaderExample` (SwiftUI with the
app delegate), `DMUnLoaderExample-Injected` (SwiftUI with a manager the app owns),
`DMUnLoaderExample-UIKit`, or `DMUnLoaderExample-CustomManager` (a loading manager written by the
host). The example of 1.0.x, which resolves the package through both CocoaPods and Swift Package
Manager as described in
[Using Swift Package Manager and CocoaPods with the same SDK](https://medium.com/@mykola.dementiev/how-to-seamlessly-use-swift-package-manager-spm-and-cocoapods-pod-together-with-the-same-sdk-1b80a2051c14),
remains at the tag `1.0.3`.

How the package is tested:

- Package tests: the state and the policies of the HUD, the managers and their timers, the
  adapters with hand-written spies, the views, and snapshots of the views.
- Tests hosted in the example app: the HUD windows of real scenes, two scenes on an iPad
  included, the touches they take and let through, and what the HUD draws under Reduce
  Transparency.
- UI tests: Retry, Close and taps on and outside the card, the touches that reach the app with
  and without a HUD in the four integrations, the texts in other languages and right to left,
  the failure HUD over content compared with reference pictures, and accessibility audits of the
  HUD, which leave out contrast and, for the loading HUD, clipped text and the readability of
  its "Loading..." label.
- CI also lints, compares the public interface with a committed baseline, builds a consumer
  package and every Swift block of this README and of the documentation catalog, builds the
  documentation, lints the podspec, runs the tests under the Thread Sanitizer, and fails below a
  coverage floor.

## Versions and migration

DMUnLoader follows semantic versioning. [CHANGELOG.md](CHANGELOG.md) records every release.

Coming from 1.0.x: no declaration was removed, and the new settings default to the released
behaviour. Building needs Xcode 26, the Swift 6.2 compiler that the sources already needed. Some
behaviour changed, and the changelog lists each change. The ones most likely to matter:

- Retry, Close and a tap outside the card work on iOS 18 and 26, where the buttons of the failure
  HUD did nothing;
- settings and states compare what they show, and a provider and a manager are equal only to
  themselves;
- a loading text or a success message of more than one line is centred by default;
- the default failure title reads "An error has occurred!";
- the HUD hides the content under it from assistive technology, as described above.

## Known issues

The default card of the HUD, white text on gray at opacity 0.8, does not reach the contrast of
4.5:1; an app that needs it sets its own colours through the settings types, or supplies its own
views through `DMLoadingViewProvider`.

At large accessibility text sizes the default loading view, at most 150 points wide, cuts its
text; an app that needs those sizes gives `DMProgressViewDefaultSettings` a larger
`frameGeometrySize`, or supplies its own loading view.

A success or a failure hides after 2 seconds by default. With VoiceOver or Switch Control that can be
too short to reach Retry; the Accessibility section names the settings that give more time.

## The family

DMUnLoader is one of three packages that share their conventions:

- [DMAction](https://github.com/nikolay-dementiev/DMAction): composes completion-based actions
  with retries and fallbacks. The Retry button of DMUnLoader runs one.
- [DMVariableBlurView](https://github.com/nikolay-dementiev/DMVariableBlurView): a blur whose
  radius changes from row to row. DMUnLoader draws it behind its HUD.

## Contributing, security, licence

- [CONTRIBUTING.md](CONTRIBUTING.md): how to build, test and propose a change.
- [SECURITY.md](SECURITY.md): how to report a vulnerability. Not in a public issue.
- DMUnLoader is available under the MIT License. See [LICENSE](LICENSE).
- The HUD window was inspired by [Custom HUDs in SwiftUI](https://www.fivestars.blog/articles/swiftui-hud/)
  and [How to layer multiple windows in SwiftUI](https://www.fivestars.blog/articles/swiftui-windows/).

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fnikolay-dementiev%2FDMUnLoader?ref=badge_large)
