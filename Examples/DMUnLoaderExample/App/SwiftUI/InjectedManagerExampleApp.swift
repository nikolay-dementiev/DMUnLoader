import SwiftUI
import DMUnLoader

/// The SwiftUI integration without an app delegate of the library.
///
/// The app owns its loading manager and gives it to `DMRootLoadingView(manager:content:)`,
/// which shows the HUD over the scene of the window the view is in.
struct InjectedManagerExampleApp: App {
    @StateObject private var loadingManager = DMLoadingManagerMain(
        state: .none,
        settings: ExampleLoadingSettings(autoHideDelay: LaunchOptions.current.autoHideDelay ?? .seconds(2))
    )

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView(manager: loadingManager) { loadingManager in
                DemoScreen(loadingManager: loadingManager)
            }
        }
    }
}
