//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Whether a tap on the card or outside it dismisses a phase: a success and a failure follow
/// the rule of their kind; loading waits for its result.
package enum DismissPolicy {
    package static func tapDismisses(_ phase: HUDPhase, on target: HUDTapTarget, rules: DMHUDDismissalRules) -> Bool {
        switch phase {
        case .none:
            return true
        case .loading:
            return false
        case .success, .failure, .failureWithRetry:
            guard let dismissal = rules.dismissal(for: phase) else {
                return false
            }
            switch target {
            case .card:
                return dismissal.cardTapHides
            case .backdrop:
                return dismissal.backdropTapHides
            }
        }
    }
}
