import SwiftUI
import DMUnLoader

/// The SwiftUI integration with a loading manager written by the host.
///
/// The manager type is the generic argument of the app delegate and of the root view.
struct CustomManagerExampleApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: DMAppDelegate<StickyLoadingManager>

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView { (loadingManager: StickyLoadingManager) in
                DemoScreen(loadingManager: loadingManager)
            }
        }
    }
}
