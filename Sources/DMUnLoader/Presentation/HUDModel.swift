//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// What the view model of the HUD reads and acts on: the phase of the HUD, the rules for a tap,
/// and a way to ask for a hide. An adapter over the owner of the state implements it, so the view
/// model does not name that owner.
@MainActor
package protocol HUDModel {
    /// The phase the HUD is in. It is read on every access: an implementation keeps no copy, because
    /// a tap decides on the phase of that moment.
    var phase: HUDPhase { get }

    /// How a tap hides each kind of HUD. Read on every access, as the rules of the moment of a tap
    /// are the ones that apply.
    var dismissalRules: DMHUDDismissalRules { get }

    /// Asks the owner of the state to hide the HUD. The owner may refuse and keep its state; the
    /// caller reads `phase` afterwards to know whether the HUD went.
    func hide()
}
