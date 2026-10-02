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
    /// The manager the scene shows, with a way to present it that keeps its type.
    private struct CurrentManager {
        let id: ObjectIdentifier
        let present: @MainActor (any HUDOverlayPresenting) -> Void
    }

    private var presenter: (any HUDOverlayPresenting)?
    private var currentManager: CurrentManager?
    private var presentedManager: ObjectIdentifier?

    package init() {}

    /// The scene connected, and `presenter` shows HUDs over it. A manager set before is
    /// shown now.
    package func sceneDidConnect(presenter: any HUDOverlayPresenting) {
        self.presenter = presenter
        presentedManager = nil
        presentCurrentManager()
    }

    /// The loading manager of the scene was set, to `loadingManager`. The same manager again
    /// keeps its HUD; another one replaces it; `nil` removes it.
    package func loadingManagerDidChange<LM: DMLoadingManager>(to loadingManager: LM?) {
        guard let loadingManager else {
            currentManager = nil
            presentedManager = nil
            presenter?.dismiss()
            return
        }
        currentManager = CurrentManager(id: ObjectIdentifier(loadingManager)) { presenter in
            presenter.present(loadingManager)
        }
        presentCurrentManager()
    }

    private func presentCurrentManager() {
        guard let presenter, let currentManager, presentedManager != currentManager.id else {
            return
        }
        currentManager.present(presenter)
        presentedManager = currentManager.id
    }
}
