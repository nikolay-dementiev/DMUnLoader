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

/// The failure channel as a trailing closure that keeps the last failure in the view's state.
struct InjectedRootWithFailureChannel: View {
    let manager: DMLoadingManagerMain
    @State private var lastFailure: DMHUDAttachmentFailure?

    var body: some View {
        DMRootLoadingView(manager: manager) { loadingManager in
            Text(verbatim: "\(loadingManager.loadableState)")
        } onAttachmentFailure: { failure in
            lastFailure = failure
        }
    }
}

/// Every argument labelled, with a manager type the host chooses.
struct InjectedRootLabelled<LM: DMLoadingManager>: View {
    let manager: LM

    var body: some View {
        DMRootLoadingView(
            manager: manager,
            content: { loadingManager in Text(verbatim: "\(type(of: loadingManager))") },
            onAttachmentFailure: { failure in
                print(failure.description)
            }
        )
    }
}
