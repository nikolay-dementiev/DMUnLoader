import SwiftUI
import DMUnLoader

/// The SwiftUI integration.
///
/// `DMAppDelegate` installs the scene delegate that owns the HUD window, and
/// `DMRootLoadingView` creates the loading manager and hands it to that scene delegate.
struct SwiftUIExampleApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: DMAppDelegateType

    var body: some Scene {
        WindowGroup {
            if let autoHideDelay = LaunchOptions.current.autoHideDelay {
                HostOwnedManagerRoot(
                    autoHideDelay: autoHideDelay,
                    startsWithFailure: LaunchOptions.current.startsWithFailure
                )
            } else {
                DMRootLoadingView { loadingManager in
                    DemoScreen(loadingManager: loadingManager)
                        .modifier(SceneDelegateRegistration())
                }
            }
        }
    }
}

/// A host that wants its own settings creates the manager itself and gives it to the scene
/// delegate, which is what `DMRootLoadingView` does with a default manager.
struct HostOwnedManagerRoot: View {
    @EnvironmentObject private var sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>
    @StateObject private var loadingManager: DMLoadingManagerMain

    init(autoHideDelay: Duration, startsWithFailure: Bool = false) {
        let initialState: DMLoadableType = startsWithFailure
            ? .failure(
                error: DemoError.serverDidNotAnswer,
                provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
            )
            : .none
        _loadingManager = StateObject(
            wrappedValue: DMLoadingManagerMain(
                state: initialState,
                settings: ExampleLoadingSettings(autoHideDelay: autoHideDelay)
            )
        )
    }

    var body: some View {
        DemoScreen(loadingManager: loadingManager)
            .onAppear {
                sceneDelegate.loadingManager = loadingManager
            }
    }
}
