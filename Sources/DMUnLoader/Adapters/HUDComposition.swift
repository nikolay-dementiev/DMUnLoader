//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

/// What a window needs to show the HUD of one loading manager, made from that manager: the root view
/// of the window, whether a HUD is shown, the level of the window, and what an accessibility escape
/// does. The manager's type is known where a composition is made and nowhere after that.
///
/// The view model of the HUD is made once, with the composition, and is the one that the scene view,
/// the loading view and the Close command of a failure use.
///
/// A composition holds the manager strongly, as the root view it makes does. The window must not
/// hold the composition: it takes `escape`, which holds the manager weakly.
@MainActor
package struct HUDComposition {
    private let rootView: @MainActor (_ onStateChange: @escaping @MainActor (DMLoadableType) -> Void) -> AnyView
    private let readsShowsHUD: @MainActor () -> Bool
    private let readsWindowLevel: @MainActor () -> UIWindow.Level

    /// What an accessibility escape does: the same as a tap outside the card, and whether the HUD
    /// went. It holds the manager weakly, so a window that keeps it keeps no replaced manager alive,
    /// and it reports that nothing went once the manager is gone. It makes a view model of its own
    /// on each call, because the view model of the composition holds the manager strongly.
    package let escape: @MainActor () -> Bool

    /// Makes nothing that reads `loadingManager`: every read happens when a member is used.
    package init<LM: DMLoadingManager>(_ loadingManager: LM) {
        let viewModel = DefaultHUDViewModel(model: LoadingManagerHUDModel(loadingManager))
        rootView = { onStateChange in
            AnyView(
                DMHudSceneView(
                    loadingManager: loadingManager,
                    viewModel: viewModel,
                    onStateChange: onStateChange
                )
                .modifier(SystemAccessibilitySettings())
            )
        }
        readsShowsHUD = { loadingManager.loadableState.showsHUD }
        readsWindowLevel = { loadingManager.settings.hudWindowLevel }
        escape = { [weak loadingManager] in
            guard let loadingManager else { return false }
            return DefaultHUDViewModel(model: LoadingManagerHUDModel(loadingManager)).backdropTapped()
        }
    }

    /// Whether a HUD is shown by the manager now. Read from the manager on each access: a composition
    /// may be made before the window is shown.
    package var showsHUD: Bool {
        readsShowsHUD()
    }

    /// The level that the manager's settings give the window now. Read from the manager on each access.
    package var windowLevel: UIWindow.Level {
        readsWindowLevel()
    }

    /// The view that the window shows.
    ///
    /// - Parameter onStateChange: Called with the state of the manager when the view appears and
    ///   whenever the state changes. The window owns the view, so the closure should hold the window
    ///   weakly.
    package func makeRoot(onStateChange: @escaping @MainActor (DMLoadableType) -> Void) -> AnyView {
        rootView(onStateChange)
    }
}
