//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// What assistive technology needs to hear when the state of a HUD changes.
package enum HUDAccessibilityTransition: Equatable, Sendable {
    /// A HUD appeared.
    case entered
    /// The HUD stays and shows another phase, or another state of its phase.
    case contentChanged
    /// The HUD went.
    case left
    /// Nothing that assistive technology needs to hear.
    case nothing

    /// - Parameter stateChanged: Whether the state is another one, also when its phase is the
    ///   same: a failure in the place of another failure changes what the HUD shows.
    package init(from previous: HUDPhase, to next: HUDPhase, stateChanged: Bool) {
        switch (previous.showsHUD, next.showsHUD) {
        case (false, true):
            self = .entered
        case (true, false):
            self = .left
        case (true, true):
            self = previous != next || stateChanged ? .contentChanged : .nothing
        case (false, false):
            self = .nothing
        }
    }
}
