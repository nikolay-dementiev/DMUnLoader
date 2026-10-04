//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// A scene the HUD can be shown over. The scene delegate of the library and a root view with
/// an injected loading manager both connect a HUD lifecycle to one.
@MainActor
package protocol HUDScene: AnyObject {
    /// A presenter that shows HUDs over this scene.
    func makeHUDPresenter() -> any HUDOverlayPresenting

    /// Calls `onDisconnect` when this scene disconnects, for as long as the returned
    /// observation is kept.
    func observeDisconnect(_ onDisconnect: @escaping @MainActor () -> Void) -> AnyObject
}
