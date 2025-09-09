import SwiftUI
import DMUnLoader

struct HudSceneView: View {
    @ObservedObject var loadingManager: DMLoadingManager

  var body: some View {
    Color.clear
      .ignoresSafeArea(.all)
      .hudCenter(loadingManager: loadingManager) {
          DMLoadingView(loadingManager: loadingManager,
                        provider: DefaultDMLoadingViewProvider())
      }
  }
}

struct DMLoadingManagerSTSettings: DMLoadingManagerSettings {
    
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
    internal init(autoHideDelay: Duration = .seconds(3)) {
        self.autoHideDelay = autoHideDelay
    }
}
