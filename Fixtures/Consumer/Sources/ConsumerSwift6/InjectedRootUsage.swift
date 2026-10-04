import Combine
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

/// A loading manager the app writes itself: the released protocol, with the released calls and
/// a published state that a subscription can observe.
@MainActor
final class ConsumerLoadingManager: DMLoadingManager {
    @Published private(set) var loadableState: DMLoadableType = .none
    let settings: any DMLoadingManagerSettings = DMLoadingManagerDefaultSettings()

    init() {}

    func showLoading<PR: DMLoadingViewProvider>(provider: PR) {
        loadableState = .loading(provider: provider.eraseToAnyViewProvider())
    }

    func showSuccess<PR: DMLoadingViewProvider>(_ message: any DMLoadableTypeSuccess, provider: PR) {
        loadableState = .success(message, provider: provider.eraseToAnyViewProvider())
    }

    func showFailure<PR: DMLoadingViewProvider>(_ error: any Error, provider: PR, onRetry: (any DMAction)?) {
        loadableState = .failure(error: error, provider: provider.eraseToAnyViewProvider(), onRetry: onRetry)
    }

    func hide() {
        loadableState = .none
    }
}

/// Subscribes to the published state of a manager the app writes, and calls the released
/// three-argument `showFailure` of the protocol.
@MainActor
func observeConsumerLoadingManager() -> AnyCancellable {
    let manager = ConsumerLoadingManager()
    let subscription = manager.$loadableState.sink { _ in }
    manager.showFailure(DMAppError.custom("The server did not answer."), provider: DefaultDMLoadingViewProvider(), onRetry: nil)
    return subscription
}
