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

/// A concrete implementation of the `DMLoadingManagerSettings` protocol.
/// This struct provides default settings for a loading manager, including
/// an optional `autoHideDelay` parameter during initialization.
struct DMLoadingManagerDefaultSettings: DMLoadingManagerSettings {
    
    /// The duration after which the loading state should automatically hide.
    /// Defaults to 2 seconds if no value is provided during initialization.
    let autoHideDelay: Duration
    
    /// Initializes a new instance of `DMLoadingManagerDefaultSettings`.
    /// - Parameter autoHideDelay: The duration after which the loading state
    ///   should automatically hide. Defaults to `.seconds(2)` if not specified.
    /// - Example:
    ///   ```swift
    ///   let defaultSettings = DMLoadingManagerDefaultSettings()
    ///   print("Default auto-hide delay: \(defaultSettings.autoHideDelay)") // Output: "Default auto-hide delay: 2 seconds"
    ///
    ///   let customSettings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(5))
    ///   print("Custom auto-hide delay: \(customSettings.autoHideDelay)") // Output: "Custom auto-hide delay: 5 seconds"
    ///   ```
    init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}
