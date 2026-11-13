//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Shows the HUD of one root view over the scene that view is in. The view reports where it
/// moved; the HUD waits while the view is in no scene and follows it from scene to scene.
@MainActor
package final class RootViewHUDAttachment<Content> {
    private let lifecycle = HUDOverlayLifecycle<Content>()
    private weak var scene: (any HUDScene<Content>)?
    private var disconnectObservation: AnyObject?

    package init() {}

    /// The root view was given `presentation`. Its HUD is shown over the scene of the view, now or
    /// once the view is in one; another identity takes over the HUD.
    package func presentationDidChange(to presentation: HUDPresentation<Content>) {
        lifecycle.presentationDidChange(to: presentation)
    }

    /// The root view moved into a window of `scene`, or, with `nil`, into no window of a
    /// scene. The same scene again keeps the HUD.
    package func viewDidMove(to scene: (any HUDScene<Content>)?) {
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
