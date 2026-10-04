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
    var autoHideDelay: Duration { get }

    /// How a success and a failure leave the screen.
    ///
    /// `DMLoadingManagerMain` schedules its auto-hide from these rules. The HUD applies the tap
    /// rules whatever the manager; a manager of the host's own decides its auto-hide itself. A
    /// conforming type that does not implement this property gets `DMHUDDismissalRules()`.
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
    var backdrop: DMHUDBackdrop { get }
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
    }
}
