import DMUnLoader
import SwiftUI

/// An app that owns its loading manager and has no app delegate of the library.
struct InjectedManagerApp: App {
    @StateObject private var manager = DMLoadingManagerMain(
        state: .none,
        settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(4))
    )

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView(manager: manager) { loadingManager in
                Text(verbatim: "\(loadingManager.settings.autoHideDelay)")
            }
        }
    }
}

/// Every argument labelled, with a manager type the host chooses.
struct InjectedRootLabelled<LM: DMLoadingManager>: View {
    let manager: LM

    var body: some View {
        DMRootLoadingView(
            manager: manager,
            content: { loadingManager in Text(verbatim: "\(type(of: loadingManager))") }
        )
    }
}
