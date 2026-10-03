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
    
    /// The duration after which the loading state should automatically hide.
    /// - Example:
    ///   ```swift
    ///   let settings: DMLoadingManagerSettings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(3))
    ///   print("Auto-hide delay: \(settings.autoHideDelay)") // Output: "Auto-hide delay: 3 seconds"
    ///   ```
    var autoHideDelay: Duration { get }
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

    /// - Parameter autoHideDelay: How long a success or a failure stays before it hides by
    ///   itself. 2 seconds when omitted, as for `DMLoadingManagerMain()`.
    public init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}
