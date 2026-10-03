//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

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
}

extension DMLoadingManagerSettings {
    /// `DMHUDDismissalRules()`: each kind hides after `autoHideDelay` and on any tap, as before
    /// 1.1.0.
    public var hudDismissal: DMHUDDismissalRules {
        DMHUDDismissalRules()
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

    /// - Parameters:
    ///   - autoHideDelay: How long a success or a failure stays before it hides by itself.
    ///     2 seconds when omitted, as for `DMLoadingManagerMain()`.
    ///   - hudDismissal: How a success and a failure leave the screen.
    ///     `DMHUDDismissalRules()` when omitted: the behaviour before 1.1.0.
    public init(
        autoHideDelay: Duration = .seconds(2),
        hudDismissal: DMHUDDismissalRules = DMHUDDismissalRules()
    ) {
        self.autoHideDelay = autoHideDelay
        self.hudDismissal = hudDismissal
    }
}
