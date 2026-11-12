//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// What a scene shows as its HUD: the identity of the owner of the state, and the content that a
/// presenter shows for it. The layer that knows the owner makes the content, so the lifecycle of the
/// HUD decides when to show it without naming the owner or knowing what the content is made of.
///
/// The content holds the owner as long as the layer that made it decides, and the value holds the
/// content until it is replaced or dropped, so an owner that only the HUD refers to stays alive for
/// as long as the HUD is wanted.
@MainActor
package struct HUDPresentation<Content> {
    /// Tells two presentations of the same owner from those of two owners: the same identity again
    /// keeps the HUD, another one replaces it. The content is not compared.
    package let id: ObjectIdentifier

    /// What a presenter shows for the owner.
    package let content: Content

    package init(id: ObjectIdentifier, content: Content) {
        self.id = id
        self.content = content
    }
}
