//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// When a HUD hides by itself.
public struct DMHUDAutoHide: Hashable, Sendable {
    package enum Rule: Hashable, Sendable {
        case afterAutoHideDelay
        case never
        case after(Duration)
    }

    package let rule: Rule

    private init(rule: Rule) {
        self.rule = rule
    }

    /// After `autoHideDelay` of the loading manager's settings. The default.
    public static let afterAutoHideDelay = DMHUDAutoHide(rule: .afterAutoHideDelay)

    /// Never. The HUD stays until a tap that its rules allow, Close, `hide()` or another state.
    public static let never = DMHUDAutoHide(rule: .never)

    /// After `delay`, whatever `autoHideDelay` is.
    public static func after(_ delay: Duration) -> DMHUDAutoHide {
        DMHUDAutoHide(rule: .after(delay))
    }
}

/// How one kind of HUD leaves the screen: by itself, by a tap on its card, or by a tap outside
/// its card. The buttons of a failure keep their actions: Close hides it; Retry runs the retry
/// action and leaves the HUD as it is.
public struct DMHUDDismissal: Hashable, Sendable {
    /// When the HUD hides by itself.
    public var autoHide: DMHUDAutoHide

    /// Whether a tap on the card hides the HUD. A tap on a button of the card is not a tap on
    /// the card.
    public var cardTapHides: Bool

    /// Whether a tap outside the card hides the HUD.
    public var backdropTapHides: Bool

    /// The defaults are what a success and a failure did before 1.1.0: hide after
    /// `autoHideDelay`, and on any tap.
    public init(
        autoHide: DMHUDAutoHide = .afterAutoHideDelay,
        cardTapHides: Bool = true,
        backdropTapHides: Bool = true
    ) {
        self.autoHide = autoHide
        self.cardTapHides = cardTapHides
        self.backdropTapHides = backdropTapHides
    }
}

/// How a success, a failure without Retry and a failure with Retry leave the screen.
///
/// The loading HUD has no rules: it stays until the next state, and taps do nothing.
///
/// A failure with Retry that waits for the user, and leaves through Close, a tap outside its
/// card, or another state:
///
/// ```swift
/// DMHUDDismissalRules(
///     failureWithRetry: DMHUDDismissal(autoHide: .never, cardTapHides: false)
/// )
/// ```
public struct DMHUDDismissalRules: Hashable, Sendable {
    /// A success.
    public var success: DMHUDDismissal

    /// A failure shown without a retry action.
    public var failureWithoutRetry: DMHUDDismissal

    /// A failure shown with a retry action.
    public var failureWithRetry: DMHUDDismissal

    /// Every kind defaults to `DMHUDDismissal()`: the behaviour before 1.1.0.
    public init(
        success: DMHUDDismissal = DMHUDDismissal(),
        failureWithoutRetry: DMHUDDismissal = DMHUDDismissal(),
        failureWithRetry: DMHUDDismissal = DMHUDDismissal()
    ) {
        self.success = success
        self.failureWithoutRetry = failureWithoutRetry
        self.failureWithRetry = failureWithRetry
    }

    /// The rule of the kind a phase shows; none for no state and for loading.
    package func dismissal(for phase: HUDPhase) -> DMHUDDismissal? {
        switch phase {
        case .success:
            return success
        case .failure:
            return failureWithoutRetry
        case .failureWithRetry:
            return failureWithRetry
        case .none, .loading:
            return nil
        }
    }
}

/// Where a tap on a shown HUD lands: on its card, or outside it.
package enum HUDTapTarget: Sendable {
    case card
    case backdrop
}
