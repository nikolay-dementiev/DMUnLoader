//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Decides when the HUD of one scene is presented, from what happens to the scene and to
/// its loading manager. The scene delegates report those events; a presenter does the UI
/// work.
@MainActor
package final class HUDOverlayLifecycle {
    private var presenter: (any HUDOverlayPresenting)?

    package init() {}

    /// The scene connected, and `presenter` shows HUDs over it.
    package func sceneDidConnect(presenter: any HUDOverlayPresenting) {
        self.presenter = presenter
    }

    /// The loading manager of the scene was set, to `loadingManager`.
    package func loadingManagerDidChange<LM: DMLoadingManager>(to loadingManager: LM?) {
        guard let presenter, let loadingManager else {
            return
        }
        presenter.present(loadingManager)
    }
}
