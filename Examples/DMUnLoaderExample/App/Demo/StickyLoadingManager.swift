import Combine
import DMUnLoader

/// A loading manager written by the host.
///
/// It keeps a success or a failure on screen until the user dismisses it: there is no
/// timer. `DMLoadingManagerMain` hides both after `settings.autoHideDelay`.
@MainActor
final class StickyLoadingManager: DMLoadingManager {
    @Published private(set) var loadableState: DMLoadableType = .none

    /// The protocol asks for settings. This manager has no timer and never reads the delay.
    let settings: any DMLoadingManagerSettings = ExampleLoadingSettings(autoHideDelay: .zero)

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
