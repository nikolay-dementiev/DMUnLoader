//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Observation

/// A loading manager for a host that keeps its state with Observation (`@State`, the typed
/// environment) and not with `ObservableObject`.
///
/// The ``DMLoadingManagerMain`` that it wraps stays the one owner of the state: this type holds the
/// manager, shows its ``loadableState`` as a property that Observation tracks, and forwards the
/// operations of the manager to it. It has no state of its own that the manager does not have, so the
/// HUD, which observes the manager as an `ObservableObject`, and a view that reads this type always
/// agree. ``manager`` is the manager to give to `DMRootLoadingView(manager:content:)`.
///
/// Everything runs on the main actor. This type holds the manager strongly, and the manager knows
/// nothing of this type, so any number of these types may wrap one manager and none of them keeps it
/// from going away once nothing else holds it. When this type goes away, it stops following the
/// manager.
///
/// Observation tracks the properties that a view reads. It is not synchronisation, and it is not a
/// lossless stream of events: a state that is equal to the one before may not notify. A host that
/// has to see every change keeps using the `loadableState` publisher of the manager.
@MainActor
@Observable
public final class DMObservableLoadingManager {

    /// The loading manager that this type wraps: the one owner of the state, and the manager to give
    /// to `DMRootLoadingView(manager:content:)`.
    public let manager: DMLoadingManagerMain

    /// The state of ``manager``, as Observation tracks it: `.none`, `.loading`, `.success` or
    /// `.failure`. It is read only here; the operations of this type, or of the manager, change it.
    public private(set) var loadableState: DMLoadableType = .none

    /// Wraps `manager`.
    /// - Parameter manager: The manager whose state this type shows. The default is a new manager
    ///   with no state shown and the default settings.
    public init(manager: DMLoadingManagerMain = DMLoadingManagerMain(state: .none, settings: DMLoadingManagerDefaultSettings())) {
        self.manager = manager
    }

    /// Shows the loading state: the same as the method of the manager.
    /// - Parameter provider: The provider of the loading view.
    public func showLoading<PR: DMLoadingViewProvider>(provider: PR) {
        manager.showLoading(provider: provider)
    }

    /// Shows the success state: the same as the method of the manager.
    /// - Parameters:
    ///   - message: A value conforming to `DMLoadableTypeSuccess`, representing the success message.
    ///   - provider: The provider of the success view.
    public func showSuccess<PR: DMLoadingViewProvider>(_ message: any DMLoadableTypeSuccess, provider: PR) {
        manager.showSuccess(message, provider: provider)
    }

    /// Shows the failure state: the same as the method of the manager.
    /// - Parameters:
    ///   - error: The error that occurred during the operation.
    ///   - provider: The provider of the error view.
    ///   - onRetry: An optional action to retry the operation. The default error view shows a Retry
    ///     button for it.
    public func showFailure<PR: DMLoadingViewProvider>(
        _ error: any Error,
        provider: PR,
        onRetry: (any DMAction)? = nil
    ) {
        manager.showFailure(error, provider: provider, onRetry: onRetry)
    }

    /// Hides the HUD, resetting the state to `.none`: the same as the method of the manager.
    public func hide() {
        manager.hide()
    }
}
