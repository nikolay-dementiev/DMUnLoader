//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Hides what lies under the HUD from assistive technology, and shows it again.
@MainActor
package protocol ContentUnderneathHiding: AnyObject {
    /// Hides from assistive technology the content that the HUD covers.
    func hideContentUnderneath()

    /// Shows that content again, as it was before it was hidden.
    func restoreContentUnderneath()
}

/// What the HUD tells assistive technology.
@MainActor
package protocol AccessibilityAnnouncer: AnyObject {
    /// The element that assistive technology focuses now, if any.
    var focusedElement: AnyObject? { get }

    /// Whether `element` is still on screen, so that the focus can return to it.
    func isOnScreen(_ element: AnyObject) -> Bool

    /// Tells assistive technology that the screen changed, focusing `element`, or the first
    /// element of the screen when it is `nil`.
    func screenChanged(focusing element: AnyObject?)
}

/// Moves the focus of assistive technology into a HUD and back, tells it when the HUD shows
/// another state, and keeps the content under the HUD out of its reach while the HUD is shown.
@MainActor
package final class HUDAccessibilityCoordinator {
    private let announcer: any AccessibilityAnnouncer
    private let contentHider: any ContentUnderneathHiding
    private var phase: HUDPhase = .none
    private var state: AnyHashable?
    private weak var focusBeforeHUD: AnyObject?

    package init(announcer: any AccessibilityAnnouncer, contentHider: any ContentUnderneathHiding) {
        self.announcer = announcer
        self.contentHider = contentHider
    }

    /// The HUD shows `next` now, in the state that `state` identifies. Another state in the same
    /// phase is a change of content.
    package func stateDidChange(to next: HUDPhase, identifiedBy state: AnyHashable) {
        let transition = HUDAccessibilityTransition(from: phase, to: next, stateChanged: state != self.state)
        phase = next
        self.state = state
        switch transition {
        case .entered:
            focusBeforeHUD = announcer.focusedElement
            contentHider.hideContentUnderneath()
            announcer.screenChanged(focusing: nil)
        case .contentChanged:
            announcer.screenChanged(focusing: nil)
        case .left:
            giveBackTheScreen()
        case .nothing:
            break
        }
    }

    /// The presenter removed the HUD, whatever it showed.
    package func hudDidGo() {
        state = nil
        guard phase.showsHUD else {
            return
        }
        phase = .none
        giveBackTheScreen()
    }

    private func giveBackTheScreen() {
        contentHider.restoreContentUnderneath()
        let focus = focusBeforeHUD.flatMap { announcer.isOnScreen($0) ? $0 : nil }
        focusBeforeHUD = nil
        announcer.screenChanged(focusing: focus)
    }
}
