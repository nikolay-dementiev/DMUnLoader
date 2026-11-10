//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Tells the accessibility coordinator of one HUD window what the window shows, as a phase and a
/// content token, so the coordinator never receives or keeps a loading state.
///
/// The reporter compares each state with the one it was given before, whichever manager gave it, and
/// moves the revision of the token when they differ. It lives as long as the coordinator it feeds, so
/// a manager that takes over the window and shows a state equal to the last one changes nothing.
@MainActor
package final class HUDStateReporter {
    private let coordinator: HUDAccessibilityCoordinator
    private var lastState: DMLoadableType?
    private var revision = 0

    package init(coordinator: HUDAccessibilityCoordinator) {
        self.coordinator = coordinator
    }

    /// The HUD shows `state` now.
    package func report(_ state: DMLoadableType) {
        // No state before this one counts as a change, as the first state of a HUD is.
        if state != lastState {
            revision += 1
        }
        lastState = state
        coordinator.stateDidChange(to: state.phase, content: HUDContentToken(revision: revision))
    }

    /// The presenter removed the HUD, whatever it showed. The coordinator forgets the token it kept,
    /// so the next state enters the screen again, whether or not it equals the last one.
    package func hudDidGo() {
        coordinator.hudDidGo()
    }
}
