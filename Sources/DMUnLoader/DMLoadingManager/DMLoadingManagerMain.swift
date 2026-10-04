//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Foundation
import Combine

/// A `ViewModel` responsible for managing and handling loading states in a user interface.
/// This class conforms to `DMLoadingManager` and provides functionality to
/// show loading, success, failure, and hidden states, as well as manage an inactivity timer.
@MainActor
public final class DMLoadingManagerMain: DMLoadingManager {
    
    /// The settings used by the loading manager to configure its behavior, such as auto-hide delay.
    public let settings: any DMLoadingManagerSettings
    
    /// The current loadable state of the manager (e.g., `.none`, `.loading`, `.success`, `.failure`).
    /// - Note: This property is thread-safe and emits changes via `loadableStateSubject`.
    @Published public internal(set) var loadableState: DMLoadableType {
        willSet {
            handleInactivityTimer(forState: newValue)
        }
    }
    
    /// A cancellable subscription used to manage the inactivity timer.
    private var inactivityTimerCancellable: AnyCancellable?
    
    /// Runs the auto-hide once the delay of `settings` has passed.
    private let autoHideScheduler: any AutoHideScheduler
    
    /// Changes whenever a pending auto-hide is stopped, so a hide the scheduler delivers
    /// after that cannot hide a newer state.
    private var autoHideGeneration = 0
    
    /// Creates a manager in `state` that hides a success or a failure as its `settings` say, by
    /// default once `settings.autoHideDelay` has passed. A view provider's
    /// `loadingManagerSettings` is not read.
    /// - Parameters:
    ///   - state: The state the manager starts in.
    ///   - settings: The settings of the manager.
    /// - Example:
    ///   ```swift
    ///   let loadingManager = DMLoadingManagerMain(
    ///       state: .none,
    ///       settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(3))
    ///   )
    ///   ```
    public init(state loadableState: DMLoadableType,
                settings: any DMLoadingManagerSettings) {
        self.loadableState = loadableState
        self.settings = settings
        self.autoHideScheduler = RunLoopAutoHideScheduler()
        
        handleInactivityTimer(forState: loadableState)
    }
    
    /// Creates a manager whose auto-hide runs on `autoHideScheduler`, so a test decides when
    /// the delay has passed.
    package init(state loadableState: DMLoadableType,
                 settings: any DMLoadingManagerSettings,
                 autoHideScheduler: any AutoHideScheduler) {
        self.loadableState = loadableState
        self.settings = settings
        self.autoHideScheduler = autoHideScheduler
        
        handleInactivityTimer(forState: loadableState)
    }
    
    /// Creates a manager with no state shown and `DMLoadingManagerDefaultSettings()`: a success
    /// or a failure hides after 2 seconds.
    public convenience init() {
        self.init(state: .none,
                  settings: DMLoadingManagerDefaultSettings())
    }
    
    /// Shows the loading state, typically indicating that an operation is in progress.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showLoading()
    ///   ```
    public func showLoading<PR: DMLoadingViewProvider>(
        provider: PR
    ) {
        loadableState = .loading(
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    /// Shows the success state with a success message.
    /// - Parameter message: A value conforming to `DMLoadableTypeSuccess`, representing the success message.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showSuccess("Data loaded successfully")
    ///   ```
    public func showSuccess<PR: DMLoadingViewProvider>(
        _ message: any DMLoadableTypeSuccess,
        provider: PR
    ) {
        loadableState = .success(
            message,
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    /// Shows the failure state with an error and an optional retry action.
    /// - Parameters:
    ///   - error: The error that occurred during the operation.
    ///   - onRetry: An optional action (`DMAction`) to retry the operation.
    /// - Example:
    ///   ```swift
    ///   let retryAction = DMButtonAction({ _ in }) {
    ///       // Retry logic here
    ///   }
    ///   loadingManager.showFailure(NSError(domain: "Example", code: 404), onRetry: retryAction)
    ///   ```
    public func showFailure<PR: DMLoadingViewProvider>(
        _ error: any Error,
        provider: PR,
        onRetry: (any DMAction)? = nil
    ) {
        loadableState = .failure(
            error: error,
            provider: provider.eraseToAnyViewProvider(),
            onRetry: onRetry
        )
    }
    
    /// Hides the loading state, resetting it to `.none`.
    /// - Example:
    ///   ```swift
    ///   loadingManager.hide()
    ///   ```
    public func hide() {
        stopInactivityTimer()
        loadableState = .none
    }
    
    // MARK: Timer Management
    
    private func handleInactivityTimer(forState state: DMLoadableType) {
        let delay = AutoHidePolicy.delay(
            for: state.phase,
            rules: settings.hudDismissal,
            autoHideDelay: settings.autoHideDelay
        )
        if let delay {
            startInactivityTimer(after: delay)
        } else {
            stopInactivityTimer()
        }
    }
    
    /// Starts the inactivity timer, which automatically hides the loading state after `delay`.
    private func startInactivityTimer(after delay: Duration) {
        stopInactivityTimer()
        let generation = autoHideGeneration
        inactivityTimerCancellable = autoHideScheduler.schedule(after: delay) { [weak self] in
            guard let self, self.autoHideGeneration == generation else {
                return
            }
            self.hide()
        }
    }
    
    /// Stops the inactivity timer, canceling any pending auto-hide operations.
    private func stopInactivityTimer() {
        inactivityTimerCancellable?.cancel()
        inactivityTimerCancellable = nil
        autoHideGeneration &+= 1
    }
}

// MARK: - Hashable Conformance

extension DMLoadingManagerMain: Hashable {
    
    /// Compares two managers by identity: a manager is equal only to itself.
    /// - Parameters:
    ///   - lhs: The left-hand side manager.
    ///   - rhs: The right-hand side manager.
    /// - Returns: `true` if both are the same object; otherwise, `false`.
    nonisolated public static func == (lhs: DMLoadingManagerMain,
                                       rhs: DMLoadingManagerMain) -> Bool {
        lhs === rhs
    }

    /// Hashes the identity of the manager into the provided hasher.
    /// - Parameter hasher: The hasher to use for combining the identity.
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
