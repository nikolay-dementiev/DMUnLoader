# ``DMUnLoader``

A HUD for the loading, success and failure states of an iOS app, for SwiftUI and UIKit.

## Overview

A loading manager holds the state that the HUD shows. Call
``DMLoadingManager/showLoading(provider:)``, ``DMLoadingManager/showSuccess(_:provider:)``,
``DMLoadingManager/showFailure(_:provider:onRetry:)`` or ``DMLoadingManager/hide()``, and the
HUD follows. ``DMLoadingManagerMain`` is the manager of the library: by default it hides a
success or a failure 2 seconds after it appears, and its settings change that.

The HUD is shown in a window of its own over the scene. While it is shown, it takes the
touches of the scene, and assistive technology does not reach the content under it. A view
provider supplies the view of each state: ``DefaultDMLoadingViewProvider`` draws the views of
the library with the settings it is given, and a provider of your own returns any view.

```swift
import DMUnLoader
import SwiftUI

struct ContentView: View {
    @StateObject private var loadingManager = DMLoadingManagerMain()
    private let provider = DefaultDMLoadingViewProvider()

    var body: some View {
        DMRootLoadingView(manager: loadingManager) { manager in
            Button("Load") {
                manager.showLoading(provider: provider)
                Task {
                    do {
                        try await Task.sleep(for: .seconds(1))
                        manager.showSuccess("Loaded", provider: provider)
                    } catch {
                        manager.showFailure(error, provider: provider)
                    }
                }
            }
        }
    }
}
```

The loading HUD stays until the next state; the success hides by itself after 2 seconds.

## Topics

### Essentials

- ``DMRootLoadingView``
- ``DMLoadingManager``
- ``DMLoadingManagerMain``
- ``DMLoadableType``
- ``DMHUDAttachmentFailure``

### The App and Scene Delegates

- ``DMAppDelegate``
- ``DMAppDelegateType``
- ``DMSceneDelegateBase``
- ``DMSceneDelegateUIKit``
- ``DMSceneDelegateTypeUIKit``
- ``DMSceneDelegateHelper``

### How the HUD Leaves and What Lies Behind It

- ``DMLoadingManagerSettings``
- ``DMLoadingManagerDefaultSettings``
- ``DMHUDDismissalRules``
- ``DMHUDDismissal``
- ``DMHUDAutoHide``
- ``DMHUDBackdrop``

### The Views of the States

- ``DMLoadingViewProvider``
- ``DefaultDMLoadingViewProvider``
- ``AnyDMLoadingViewProvider``
- ``AnyDMLoadingViewProviderTypeErasurer``

### The Loading View

- ``DMProgressViewSettings``
- ``DMProgressViewDefaultSettings``
- ``ProgressTextProperties``
- ``ProgressIndicatorProperties``

### The Error View

- ``DMErrorViewSettings``
- ``DMErrorDefaultViewSettings``
- ``ErrorTextSettings``
- ``ErrorImageSettings``
- ``ActionButtonSettings``
- ``AnyButtonStyle``

### The Success View

- ``DMSuccessViewSettings``
- ``DMSuccessDefaultViewSettings``
- ``SuccessTextProperties``
- ``SuccessImageProperties``
- ``CustomViewSize``

### Errors and Success Values

- ``DMError``
- ``DMAppError``
- ``DMLoadableTypeSuccess``

### Actions from DMAction

The library re-exports DMAction, the package of its retry actions, so these types need no
import of their own.

- ``DMAction``
- ``DMButtonAction``
- ``DMActionWithFallback``
- ``DMActionResultValue``
- ``DMActionResultValueProtocol``
- ``PlaceholderCopyable``
