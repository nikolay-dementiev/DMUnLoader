//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// What assistive technology needs to hear when the phase of a HUD changes.
package enum HUDAccessibilityTransition: Equatable, Sendable {
    /// A HUD appeared.
    case entered
    /// The HUD stays and shows another phase.
    case contentChanged
    /// The HUD went.
    case left
    /// Nothing that assistive technology needs to hear.
    case nothing

    package init(from previous: HUDPhase, to next: HUDPhase) {
        switch (previous.showsHUD, next.showsHUD) {
        case (false, true):
            self = .entered
        case (true, false):
            self = .left
        case (true, true):
            self = previous == next ? .nothing : .contentChanged
        case (false, false):
            self = .nothing
        }
    }
}
