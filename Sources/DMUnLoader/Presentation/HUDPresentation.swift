//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// What a scene shows as its HUD: the identity of the owner of the state, and a way to show that
/// owner through a presenter. The layer that knows the owner makes it, so the lifecycle of the HUD
/// decides when to show it without naming the owner.
///
/// The `show` action holds the owner strongly until the value is replaced or dropped, so an owner
/// that only the HUD refers to stays alive for as long as the HUD is wanted.
@MainActor
package struct HUDPresentation {
    /// Tells two presentations of the same owner from those of two owners: the same identity again
    /// keeps the HUD, another one replaces it.
    package let id: ObjectIdentifier

    /// Asks `presenter` to show the HUD of the owner.
    package let show: @MainActor (any HUDOverlayPresenting) -> Void

    package init(id: ObjectIdentifier, show: @escaping @MainActor (any HUDOverlayPresenting) -> Void) {
        self.id = id
        self.show = show
    }
}
