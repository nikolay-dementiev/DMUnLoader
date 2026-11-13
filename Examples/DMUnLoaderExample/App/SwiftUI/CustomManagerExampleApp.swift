import SwiftUI
import DMUnLoader

/// The SwiftUI integration with a loading manager written by the host.
///
/// The manager type is the generic argument of the app delegate and of the root view.
struct CustomManagerExampleApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: DMAppDelegate<StickyLoadingManager>

    var body: some Scene {
        WindowGroup {
            // Stays on the retired init(content:) on purpose: the app-delegate route still
            // ships in 1.x and this app is its test bed. 2.0.0 removes the initializer, see
            // Documentation/Migration-2.0.md.
            DMRootLoadingView { (loadingManager: StickyLoadingManager) in
                DemoScreen(loadingManager: loadingManager)
            }
        }
    }
}
