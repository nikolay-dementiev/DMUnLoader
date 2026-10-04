//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Whether a tap on the card or outside it dismisses a phase: a success and a failure follow
/// the rule of their kind; loading waits for its result, and with no state there is nothing to
/// dismiss.
package enum DismissPolicy {
    package static func tapDismisses(_ phase: HUDPhase, on target: HUDTapTarget, rules: DMHUDDismissalRules) -> Bool {
        guard let kind = phase.dismissableKind else {
            return false
        }
        return rules.dismissal(for: kind).hides(onTapAt: target)
    }
}
