# Moving to DMUnLoader 2.0

DMUnLoader 2.0.0 is planned to remove the declarations that this page marks as retired. Version
1.3.0 removes nothing and warns about nothing: each declaration still works and says in its
documentation comment that it is retired. Every "after" below works in 1.3.0 too, so you can move
on your own schedule, before you update to 2.0.0. `CHANGELOG.md` lists the same declarations under
"Deprecated".

Every Swift block on this page is compiled by `Scripts/check-manifest.sh` against the sources of
the release, in Swift 6 and in Swift 5 language mode. A "before" block compiles because the
declaration it uses still exists in 1.3.0.

## The state description: `rawValue`

Retired: `DMLoadableType.rawValue`, `DMLoadableType.init?(rawValue:)`, the `RawRepresentable`
conformance of `DMLoadableType` and its `RawValue` type alias. The initializer always returns
`nil`, because a state holds a provider and actions that no text can restore, so the conformance
cannot do what `RawRepresentable` means. Read `diagnosticDescription`, which returns the same text:
"Loading", "Error: `<error>`", "Success: `<message>`" or "None".

Before:

```swift
import DMUnLoader
import SwiftUI

struct StateLabelBefore: View {
    let loading: DMLoadingManagerMain

    var body: some View {
        Text(verbatim: loading.loadableState.rawValue)
    }
}
```

After:

```swift
import DMUnLoader
import SwiftUI

struct StateLabelAfter: View {
    let loading: DMLoadingManagerMain

    var body: some View {
        Text(verbatim: loading.loadableState.diagnosticDescription)
    }
}
```

## The `Optional` helpers: `isSomeValue()` and `unwrapValue()`

Retired: both methods. Compare with `nil`, or use `if let`, `guard let` or `??`. `unwrapValue()`
returns `Any`, so it erases the type, and the error it throws is not public: unwrap with
`guard let` and throw an error of your own.

Before:

```swift
import DMUnLoader

enum TitleError: Error {
    case missing
}

func hasTitleBefore(_ title: String?) -> Bool {
    title.isSomeValue()
}

func titleBefore(_ title: String?) throws -> String {
    guard let text = try title.unwrapValue() as? String else {
        throw TitleError.missing
    }
    return text
}
```

After:

```swift
enum TitleError: Error {
    case missing
}

func hasTitleAfter(_ title: String?) -> Bool {
    title != nil
}

func titleAfter(_ title: String?) throws -> String {
    guard let title else {
        throw TitleError.missing
    }
    return title
}
```

## `Hashable` on `EdgeInsets` and `CGSize`

Retired: the conformance of `EdgeInsets` to `Hashable`, and that of `CGSize` on iOS 17, which
iOS 18 and later provide. Each conforms a type of the system to a protocol of the system for every
app that imports DMUnLoader, and another module can declare the same conformance. For a key of a
set or a dictionary, use a type of your own that holds the values.

Before:

```swift
import DMUnLoader
import SwiftUI

func insetsBefore() -> Set<EdgeInsets> {
    [EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)]
}

func sizesBefore() -> Set<CGSize> {
    [CGSize(width: 44, height: 44)]
}
```

After:

```swift
import SwiftUI

struct InsetsKey: Hashable {
    let top: CGFloat
    let leading: CGFloat
    let bottom: CGFloat
    let trailing: CGFloat

    init(_ insets: EdgeInsets) {
        top = insets.top
        leading = insets.leading
        bottom = insets.bottom
        trailing = insets.trailing
    }
}

struct SizeKey: Hashable {
    let width: CGFloat
    let height: CGFloat

    init(_ size: CGSize) {
        width = size.width
        height = size.height
    }
}

func insetsAfter() -> Set<InsetsKey> {
    [InsetsKey(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))]
}

func sizesAfter() -> Set<SizeKey> {
    [SizeKey(CGSize(width: 44, height: 44))]
}
```

## `NSError` as `DMError` and `LocalizedError`

Retired: the conformances of `NSError` to `LocalizedError` and to `DMError`. `DMError` refines
`LocalizedError`, so they go together. Every API that shows a failure takes `any Error`, so pass
the `NSError` itself. `DMError` is for the error types your own code declares. Where an `NSError`
goes into `DMAppError.generalError`, wrap it in an error type of your own that conforms to
`DMError`. The wrapper keeps the `NSError` in a property, so the original is `underlying`, not the
error you catch. When the failure is a resource or a network failure, `DMAppError.resourceError`
with `.error(_:)` and `DMAppError.network` with `.generalError(_:)` take any `Error` and need no
wrapper.

Before:

```swift
import DMUnLoader
import Foundation

@MainActor
func showBefore(on manager: DMLoadingManagerMain) {
    let error: any DMError = NSError(domain: "Example", code: 7)
    manager.showFailure(error, provider: DefaultDMLoadingViewProvider())
}

func appErrorBefore() -> DMAppError {
    .generalError(NSError(domain: "Example", code: 7))
}
```

After:

```swift
import DMUnLoader
import Foundation

struct WrappedError: DMError {
    let underlying: NSError

    var errorDescription: String? {
        underlying.localizedDescription
    }
}

@MainActor
func showAfter(on manager: DMLoadingManagerMain) {
    let error: any Error = NSError(domain: "Example", code: 7)
    manager.showFailure(error, provider: DefaultDMLoadingViewProvider())
}

func appErrorAfter() -> DMAppError {
    .generalError(WrappedError(underlying: NSError(domain: "Example", code: 7)))
}
```

## `foregroundStyle` with an optional style

Retired: `View.foregroundStyle(_:)` for an optional style. Apply a style only when you have one,
with `if let style` in a view builder, as the modifier below does. `style ?? .primary` is not the
same: it sets a style where the retired overload leaves the one the view inherits.

Before:

```swift
import DMUnLoader
import SwiftUI

struct TintedLabelBefore: View {
    let color: Color?

    var body: some View {
        Text("Label").foregroundStyle(color)
    }
}
```

After:

```swift
import SwiftUI

extension View {
    @ViewBuilder
    func foregroundStyleIfPresent<S: ShapeStyle>(_ style: S?) -> some View {
        if let style {
            foregroundStyle(style)
        } else {
            self
        }
    }
}

struct TintedLabelAfter: View {
    let color: Color?

    var body: some View {
        Text("Label").foregroundStyleIfPresent(color)
    }
}
```

## `loadingManagerSettings` of a view provider

Retired: the `loadingManagerSettings` requirement of `DMLoadingViewProvider`, its default
implementation, the `loadingManagerSettings` argument and property of
`DefaultDMLoadingViewProvider`, and the property of the type that `eraseToAnyViewProvider()`
returns. Nothing in the library has ever acted on them: a success or a failure hides after the
delay in the settings of the loading manager that shows it, whatever provider it was shown with.
To have the settings take effect, give them to the manager with
`DMLoadingManagerMain(state:settings:)`. To keep what your app does today, drop the argument
instead.

Before:

```swift
import DMUnLoader

@MainActor
func managerBefore() -> (DMLoadingManagerMain, DefaultDMLoadingViewProvider) {
    let settings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(5))
    let provider = DefaultDMLoadingViewProvider(loadingManagerSettings: settings)
    return (DMLoadingManagerMain(), provider)
}
```

After:

```swift
import DMUnLoader

@MainActor
func managerAfter() -> (DMLoadingManagerMain, DefaultDMLoadingViewProvider) {
    let settings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(5))
    let manager = DMLoadingManagerMain(state: .none, settings: settings)
    return (manager, DefaultDMLoadingViewProvider())
}
```

## `DMRootLoadingView(content:)`

Retired: both `DMRootLoadingView` initializers named `init(content:)`, the one for a manager type
of your own and the one for `DMLoadingManagerMain`. They create the loading manager and need the
app delegate of DMUnLoader, `DMAppDelegateType` or `DMAppDelegate<YourManager>`; without it
SwiftUI stops the app when the view appears. Use `init(manager:content:)` with a manager that
your app owns. It needs no app delegate. Keep the manager alive outside the view, as the
`@StateObject` below does, and create it in a view that every window makes for itself, not in the
`App`: the retired initializers gave each window a manager of its own, and a manager that the `App`
holds is shared by all windows, so one `showLoading` would draw a HUD in each of them. A manager
type of your own is created the same way, with its own initializer in the `@StateObject`.

Before:

```swift
import DMUnLoader
import SwiftUI

@main
struct BeforeApp: App {
    @UIApplicationDelegateAdaptor private var delegate: DMAppDelegateType

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView { loadingManager in
                BeforeContent(loadingManager: loadingManager)
            }
        }
    }
}

struct BeforeContent: View {
    let loadingManager: DMLoadingManagerMain
    private let provider = DefaultDMLoadingViewProvider()

    var body: some View {
        Button("Show success") {
            loadingManager.showSuccess("Data loaded", provider: provider)
        }
    }
}
```

After:

```swift
import DMUnLoader
import SwiftUI

@main
struct AfterApp: App {
    var body: some Scene {
        WindowGroup {
            AfterRoot()
        }
    }
}

struct AfterRoot: View {
    @StateObject private var loadingManager = DMLoadingManagerMain()

    var body: some View {
        DMRootLoadingView(manager: loadingManager) { manager in
            AfterContent(loadingManager: manager)
        }
    }
}

struct AfterContent: View {
    let loadingManager: DMLoadingManagerMain
    private let provider = DefaultDMLoadingViewProvider()

    var body: some View {
        Button("Show success") {
            loadingManager.showSuccess("Data loaded", provider: provider)
        }
    }
}
```

## `ProgressIndicatorProperties.style`

Retired: the `style` property. It is always `CircularProgressViewStyle()` and cannot be changed.
Where you need the style, write `.circular`.

Before:

```swift
import DMUnLoader
import SwiftUI

struct IndicatorBefore: View {
    let properties = ProgressIndicatorProperties(size: .small, tintColor: .green)

    var body: some View {
        ProgressView()
            .progressViewStyle(properties.style)
            .controlSize(properties.size)
    }
}
```

After:

```swift
import DMUnLoader
import SwiftUI

struct IndicatorAfter: View {
    let properties = ProgressIndicatorProperties(size: .small, tintColor: .green)

    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .controlSize(properties.size)
    }
}
```

## `AnyDMLoadingViewProviderTypeErasurer`: name it through the alias

Not retired, and nothing to migrate if you already name the type `AnyDMLoadingViewProvider`. The
generic type behind the alias is an implementation detail, and 2.0.0 may replace it. Name the
alias, not the generic type, so that a replacement does not reach your code.

Before:

```swift
import DMUnLoader
import SwiftUI

@MainActor
func providerBefore() -> AnyDMLoadingViewProviderTypeErasurer<AnyView, AnyView, AnyView> {
    DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
}
```

After:

```swift
import DMUnLoader

@MainActor
func providerAfter() -> AnyDMLoadingViewProvider {
    DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
}
```

## What stays

`DMError`, `DMAppError`, `DMAppError.ResourceError` and `DMAppError.NetworkError` stay in 2.0.0.
This page retires nothing else.
