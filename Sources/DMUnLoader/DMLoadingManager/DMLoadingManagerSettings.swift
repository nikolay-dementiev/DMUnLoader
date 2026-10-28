//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit

/// The settings of a loading manager. Pass them to `DMLoadingManagerMain(state:settings:)`; a
/// view provider's `loadingManagerSettings` is not read.
public protocol DMLoadingManagerSettings {
    
    /// How long a success or a failure stays before it hides by itself, for every kind whose
    /// rule in `hudDismissal` is `.afterAutoHideDelay`, as all are by default.
    /// - Example:
    ///   ```swift
    ///   let settings: any DMLoadingManagerSettings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(3))
    ///   print("Auto-hide delay: \(settings.autoHideDelay)") // Output: "Auto-hide delay: 3.0 seconds"
    ///   ```
    ///
    /// Read when a state is shown: the hide of that state is scheduled from it.
    var autoHideDelay: Duration { get }

    /// How a success and a failure leave the screen.
    ///
    /// `DMLoadingManagerMain` schedules its auto-hide from these rules. The HUD applies the tap
    /// rules whatever the manager; a manager of the host's own decides its auto-hide itself. A
    /// conforming type that does not implement this property gets `DMHUDDismissalRules()`.
    ///
    /// Read when a state is shown, to schedule its hide, and at each tap, to decide whether the
    /// tap hides the HUD.
    var hudDismissal: DMHUDDismissalRules { get }

    /// The level of the window that shows the HUD over its scene.
    ///
    /// UIKit does not order windows within one level, so at `.normal`, the default, a window the
    /// app shows later can cover the HUD. `.normal + 1` keeps the HUD above every window of the
    /// app at `.normal`, and below the `.statusBar` and `.alert` levels.
    ///
    /// Read each time the HUD window starts showing this manager, before the window becomes
    /// visible. A conforming type that does not implement this property gets `.normal`.
    var hudWindowLevel: UIWindow.Level { get }

    /// What the HUD of the loading manager draws behind its card. The default implementation
    /// returns ``DMHUDBackdrop/variableBlur``, the backdrop of every release so far.
    ///
    /// Read at each render of the HUD.
    var backdrop: DMHUDBackdrop { get }

    /// Told when the variable blur of the backdrop could not be drawn and the plain blur of the
    /// system shows instead. The default implementation returns `nil`.
    ///
    /// The handler runs on the main actor, after the update of the HUD that applied the blur, so
    /// it may change state, for example the backdrop of your settings. The HUD does not change
    /// because of it: its state, its buttons and the way it leaves the screen stay as they are.
    ///
    /// It is called for each failure that DMVariableBlurView reports, and the HUD makes a new
    /// blur view each time a HUD appears, so a failing device reports once for each appearance
    /// of a HUD. It is never called for a backdrop other than ``DMHUDBackdrop/variableBlur``, nor
    /// under Reduce Transparency, where no blur is drawn.
    ///
    /// With a handler set, DMVariableBlurView writes no line to the unified log for the failure:
    /// the handler replaces it. Write the line yourself if you want it.
    ///
    /// Read at each render of the HUD.
    var onBackdropFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)? { get }
}

extension DMLoadingManagerSettings {
    /// `DMHUDDismissalRules()`: each kind hides after `autoHideDelay` and on any tap, as before
    /// 1.1.0.
    public var hudDismissal: DMHUDDismissalRules {
        DMHUDDismissalRules()
    }

    /// `.normal`: the level of the HUD window before 1.1.0.
    public var hudWindowLevel: UIWindow.Level {
        .normal
    }

    /// ``DMHUDBackdrop/variableBlur``: the variable blur under a black dim of opacity 0.2.
    public var backdrop: DMHUDBackdrop {
        .variableBlur
    }

    /// `nil`: no handler, and DMVariableBlurView writes a failure to the log, as before.
    public var onBackdropFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)? {
        nil
    }
}

/// The settings of a loading manager whose host chose none: a success or a failure hides 2
/// seconds after it is shown. `DMLoadingManagerMain()` uses them.
///
/// ```swift
/// let manager = DMLoadingManagerMain(
///     state: .none,
///     settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(4))
/// )
/// ```
public struct DMLoadingManagerDefaultSettings: DMLoadingManagerSettings, Sendable {

    /// How long a success or a failure stays before it hides by itself.
    public let autoHideDelay: Duration

    /// How a success and a failure leave the screen.
    public let hudDismissal: DMHUDDismissalRules

    /// The level of the window that shows the HUD.
    public let hudWindowLevel: UIWindow.Level

    /// What the HUD draws behind its card.
    public let backdrop: DMHUDBackdrop

    /// Told when the variable blur of the backdrop could not be drawn. `nil` for the initializer
    /// that has no such argument.
    public let onBackdropFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?

    /// - Parameters:
    ///   - autoHideDelay: How long a success or a failure stays before it hides by itself.
    ///     2 seconds when omitted, as for `DMLoadingManagerMain()`.
    ///   - hudDismissal: How a success and a failure leave the screen.
    ///     `DMHUDDismissalRules()` when omitted: the behaviour before 1.1.0.
    ///   - hudWindowLevel: The level of the window that shows the HUD. `.normal` when omitted:
    ///     the level before 1.1.0.
    ///   - backdrop: What the HUD draws behind its card. `.variableBlur` when omitted: the
    ///     backdrop before 1.1.0.
    public init(
        autoHideDelay: Duration = .seconds(2),
        hudDismissal: DMHUDDismissalRules = DMHUDDismissalRules(),
        hudWindowLevel: UIWindow.Level = .normal,
        backdrop: DMHUDBackdrop = .variableBlur
    ) {
        self.autoHideDelay = autoHideDelay
        self.hudDismissal = hudDismissal
        self.hudWindowLevel = hudWindowLevel
        self.backdrop = backdrop
        self.onBackdropFailure = nil
    }

    /// - Parameters:
    ///   - autoHideDelay: How long a success or a failure stays before it hides by itself.
    ///     2 seconds when omitted, as for `DMLoadingManagerMain()`.
    ///   - hudDismissal: How a success and a failure leave the screen.
    ///     `DMHUDDismissalRules()` when omitted: the behaviour before 1.1.0.
    ///   - hudWindowLevel: The level of the window that shows the HUD. `.normal` when omitted:
    ///     the level before 1.1.0.
    ///   - backdrop: What the HUD draws behind its card. `.variableBlur` when omitted: the
    ///     backdrop before 1.1.0.
    ///   - onBackdropFailure: Told when the variable blur of the backdrop could not be drawn,
    ///     on the main actor. See ``DMLoadingManagerSettings/onBackdropFailure``.
    public init(
        autoHideDelay: Duration = .seconds(2),
        hudDismissal: DMHUDDismissalRules = DMHUDDismissalRules(),
        hudWindowLevel: UIWindow.Level = .normal,
        backdrop: DMHUDBackdrop = .variableBlur,
        onBackdropFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?
    ) {
        self.autoHideDelay = autoHideDelay
        self.hudDismissal = hudDismissal
        self.hudWindowLevel = hudWindowLevel
        self.backdrop = backdrop
        self.onBackdropFailure = onBackdropFailure
    }
}
