//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Decides when the HUD of one scene is presented, from what happens to the scene and to the
/// presentation it is given. The scene delegates report those events; a presenter does the UI
/// work.
@MainActor
package final class HUDOverlayLifecycle<Content> {
    private var presenter: (any HUDOverlayPresenting<Content>)?
    private var currentPresentation: HUDPresentation<Content>?
    private var presentedID: ObjectIdentifier?

    package init() {}

    /// The scene connected, and `presenter` shows HUDs over it. A presentation set before is
    /// shown now. A presenter of an earlier connect loses its HUD first.
    package func sceneDidConnect(presenter: any HUDOverlayPresenting<Content>) {
        self.presenter?.dismiss()
        self.presenter = presenter
        presentedID = nil
        presentCurrentPresentation()
    }

    /// The HUD of the scene was set, to `presentation`. The same identity again keeps the HUD;
    /// another one replaces it; `nil` removes it.
    package func presentationDidChange(to presentation: HUDPresentation<Content>?) {
        guard let presentation else {
            currentPresentation = nil
            presentedID = nil
            presenter?.dismiss()
            return
        }
        currentPresentation = presentation
        presentCurrentPresentation()
    }

    /// The scene disconnected. Its HUD is removed; the presentation is kept and shown again when
    /// a scene connects.
    package func sceneDidDisconnect() {
        presenter?.dismiss()
        presenter = nil
        presentedID = nil
    }

    private func presentCurrentPresentation() {
        guard let presenter, let currentPresentation, presentedID != currentPresentation.id else {
            return
        }
        presenter.present(currentPresentation)
        presentedID = currentPresentation.id
    }
}

extension HUDOverlayLifecycle {
    /// Shows the HUDs of this lifecycle over `scene` from now on, and removes them when the
    /// scene disconnects. The disconnect is observed for as long as the returned observation
    /// is kept; `onDisconnect` runs after the HUD is removed.
    package func connect(
        to scene: any HUDScene<Content>,
        onDisconnect: @escaping @MainActor () -> Void = {}
    ) -> AnyObject {
        let observation = scene.observeDisconnect { [weak self] in
            self?.sceneDidDisconnect()
            onDisconnect()
        }
        sceneDidConnect(presenter: scene.makeHUDPresenter())
        return observation
    }
}
