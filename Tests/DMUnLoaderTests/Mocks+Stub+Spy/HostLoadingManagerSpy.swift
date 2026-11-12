//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import DMUnLoader

/// A loading manager of the host's own, as an app writes one that does not use `DMLoadingManagerMain`: it
/// never hides on a clock, records the `hide()` calls it gets, and announces a change through
/// `objectWillChange` before it makes the change, the order `@Published` uses.
///
/// `hide()` leaves the state as it is, like a manager that refuses to hide, unless `hideClearsState` is set.
@MainActor
final class HostLoadingManagerSpy: DMLoadingManager {
    private(set) var settings: any DMLoadingManagerSettings
    private(set) var loadableState: DMLoadableType
    private(set) var hideCount = 0
    private let hideClearsState: Bool

    init(
        loadableState: DMLoadableType = .none,
        settings: any DMLoadingManagerSettings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600)),
        hideClearsState: Bool = false
    ) {
        self.loadableState = loadableState
        self.settings = settings
        self.hideClearsState = hideClearsState
    }

    /// Required by `DMLoadingManager`: nothing shown, a delay no test reaches.
    convenience init() {
        self.init(loadableState: .none)
    }

    func showLoading<PR: DMLoadingViewProvider>(provider: PR) {
        set(.loading(provider: provider.eraseToAnyViewProvider()))
    }

    func showSuccess<PR: DMLoadingViewProvider>(_ message: any DMLoadableTypeSuccess, provider: PR) {
        set(.success(message, provider: provider.eraseToAnyViewProvider()))
    }

    func showFailure<PR: DMLoadingViewProvider>(_ error: any Error, provider: PR, onRetry: (any DMAction)?) {
        set(.failure(error: error, provider: provider.eraseToAnyViewProvider(), onRetry: onRetry))
    }

    func hide() {
        hideCount += 1
        if hideClearsState {
            set(.none)
        }
    }

    /// Changes the state: announces first and changes it after, as the `willSet` of `@Published` does, because
    /// the view of the HUD has to deliver the state the manager ended in, not the one it had at the announcement.
    func set(_ state: DMLoadableType) {
        objectWillChange.send()
        loadableState = state
    }

    /// Replaces the settings, as a manager does whose settings come from a place that changes.
    func replaceSettings(with settings: any DMLoadingManagerSettings) {
        self.settings = settings
    }

    /// Announces a change and makes none, as a manager does that sends `objectWillChange` for nothing.
    func announceWithoutChange() {
        objectWillChange.send()
    }
}
