//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Shows the HUD of the loading manager of one root view over the scene that view is in. The
/// view reports where it moved; the HUD waits while the view is in no scene and follows it
/// from scene to scene.
@MainActor
package final class RootViewHUDAttachment {
    private let lifecycle = HUDOverlayLifecycle()
    private weak var scene: (any HUDScene)?
    private var disconnectObservation: AnyObject?

    package init() {}

    /// The root view was given `loadingManager`. Its HUD is shown over the scene of the view,
    /// now or once the view is in one; another manager takes over the HUD.
    package func loadingManagerDidChange<LM: DMLoadingManager>(to loadingManager: LM) {
        lifecycle.loadingManagerDidChange(to: loadingManager)
    }

    /// The root view moved into a window of `scene`, or, with `nil`, into no window of a
    /// scene. The same scene again keeps the HUD.
    package func viewDidMove(to scene: (any HUDScene)?) {
        guard scene !== self.scene else {
            return
        }
        lifecycle.sceneDidDisconnect()
        self.scene = scene
        disconnectObservation = scene.map { scene in
            // The observation is kept until the next move: releasing it here would release
            // the observer while it reports.
            lifecycle.connect(to: scene) { [weak self] in
                self?.scene = nil
            }
        }
    }
}
