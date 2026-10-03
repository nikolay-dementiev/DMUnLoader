//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit

/// A protocol defining the settings for a loading manager.
/// Conforming types must provide an `autoHideDelay` property, which specifies
/// the duration after which the loading state should automatically hide.
///
/// This protocol allows customization of the behavior of a loading manager,
/// such as how long success or failure states remain visible before being hidden.
public protocol DMLoadingManagerSettings {
    
    /// How long a success or a failure stays before it hides by itself, for every kind whose
    /// rule in `hudDismissal` is `.afterAutoHideDelay`, as all are by default.
    /// - Example:
    ///   ```swift
    ///   let settings: any DMLoadingManagerSettings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(3))
    ///   print("Auto-hide delay: \(settings.autoHideDelay)") // Output: "Auto-hide delay: 3 seconds"
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

    /// - Parameters:
    ///   - autoHideDelay: How long a success or a failure stays before it hides by itself.
    ///     2 seconds when omitted, as for `DMLoadingManagerMain()`.
    ///   - hudDismissal: How a success and a failure leave the screen.
    ///     `DMHUDDismissalRules()` when omitted: the behaviour before 1.1.0.
    ///   - hudWindowLevel: The level of the window that shows the HUD. `.normal` when omitted:
    ///     the level before 1.1.0.
    public init(
        autoHideDelay: Duration = .seconds(2),
        hudDismissal: DMHUDDismissalRules = DMHUDDismissalRules(),
        hudWindowLevel: UIWindow.Level = .normal
    ) {
        self.autoHideDelay = autoHideDelay
        self.hudDismissal = hudDismissal
        self.hudWindowLevel = hudWindowLevel
    }
}
