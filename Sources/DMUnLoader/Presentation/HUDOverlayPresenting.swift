//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Shows the HUD of a presentation over one scene.
///
/// `Content` is what the layer that makes presentations puts into them for a presenter to show.
/// This port does not name it and puts no requirement on it. The UI work lives behind the port, so
/// the decisions about when a HUD is shown can be tested without a scene.
@MainActor
package protocol HUDOverlayPresenting<Content>: AnyObject {
    associatedtype Content

    /// Shows the HUD of `presentation`. A HUD shown before is replaced. Does nothing once the
    /// scene is gone.
    func present(_ presentation: HUDPresentation<Content>)

    /// Removes the HUD. Nothing is shown over the scene afterwards.
    func dismiss()
}
