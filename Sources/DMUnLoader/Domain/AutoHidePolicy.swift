//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Which phases hide by themselves, and after how long: a success and a failure follow the
/// rule of their kind; the loading phase waits for its result.
package enum AutoHidePolicy {
    /// The delay after which `phase` hides by itself, or `nil` when it stays.
    package static func delay(for phase: HUDPhase, rules: DMHUDDismissalRules, autoHideDelay: Duration) -> Duration? {
        guard let kind = phase.dismissableKind else {
            return nil
        }
        switch rules.dismissal(for: kind).autoHide.rule {
        case .afterAutoHideDelay:
            return autoHideDelay
        case .never:
            return nil
        case let .after(delay):
            return delay
        }
    }
}
