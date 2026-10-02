//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Shows the HUD of a loading manager over one scene.
///
/// The UI work lives behind this port, so the decisions about when a HUD is shown can be
/// tested without a scene.
@MainActor
package protocol HUDOverlayPresenting: AnyObject {
    /// Shows the HUD of `loadingManager`. A HUD shown before is replaced.
    func present<LM: DMLoadingManager>(_ loadingManager: LM)

    /// Removes the HUD. Nothing is shown over the scene afterwards.
    func dismiss()
}
