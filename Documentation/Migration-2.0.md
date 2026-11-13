# Moving to DMUnLoader 2.0

DMUnLoader 2.0.0 is planned to remove the declarations on this page. Version 1.3.0 removes
nothing and warns about nothing: each declaration still works and says in its documentation
comment that it is retired. Every "after" below works in 1.3.0 too, so you can move on your own
schedule, before you update to 2.0.0. `CHANGELOG.md` lists the same declarations under
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
