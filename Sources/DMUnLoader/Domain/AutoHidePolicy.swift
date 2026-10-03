//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Which phases hide by themselves, and after how long: a success and a failure follow the
/// rule of their kind; the loading phase waits for its result.
package enum AutoHidePolicy {
    package static func hidesAfterDelay(_ phase: HUDPhase, rules: DMHUDDismissalRules = DMHUDDismissalRules()) -> Bool {
        delay(for: phase, rules: rules, autoHideDelay: .zero) != nil
    }

    /// The delay after which `phase` hides by itself, or `nil` when it stays.
    package static func delay(for phase: HUDPhase, rules: DMHUDDismissalRules, autoHideDelay: Duration) -> Duration? {
        guard let dismissal = rules.dismissal(for: phase) else {
            return nil
        }
        switch dismissal.autoHide.rule {
        case .afterAutoHideDelay:
            return autoHideDelay
        case .never:
            return nil
        case let .after(delay):
            return delay
        }
    }
}
