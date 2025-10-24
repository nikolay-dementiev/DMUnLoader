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
    public let settings: DMLoadingManagerSettings
    
    /// The current loadable state of the manager (e.g., `.none`, `.loading`, `.success`, `.failure`).
    /// - Note: This property is thread-safe and emits changes via `loadableStateSubject`.
    @Published public internal(set) var loadableState: DMLoadableType
    
    /// A cancellable subscription used to manage the inactivity timer.
    private var inactivityTimerCancellable: AnyCancellable?
    
    /// Initializes a new instance of `DMLoadingManager`.
    /// - Parameters:
    ///   - id: A unique identifier for the loading manager. Defaults to a new `UUID`.
    ///   - state: The initial loadable state of the manager.
    ///   - settings: The settings used by the loading manager.
    /// - Example:
    ///   ```swift
    ///   let settings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(3))
    ///   let loadingManager = DMLoadingManager(state: .none, settings: settings)
    ///   ```
    public init(state loadableState: DMLoadableType,
                settings: DMLoadingManagerSettings) {
        self.loadableState = loadableState
        self.settings = settings
    }
    
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
        stopInactivityTimer()
        
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
        _ message: DMLoadableTypeSuccess,
        provider: PR
    ) {
        startInactivityTimer()
        
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
        _ error: Error,
        provider: PR,
        onRetry: DMAction? = nil
    ) {
        startInactivityTimer()
        
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
    
    /// Starts the inactivity timer, which automatically hides the loading state after the specified delay.
    private func startInactivityTimer() {
        stopInactivityTimer()
        inactivityTimerCancellable = Deferred {
            Future<Void, Never> { promise in
                promise(.success(()))
            }
        }
        .delay(for: .seconds(settings.autoHideDelay.timeInterval),
               scheduler: RunLoop.main)
        .sink(receiveValue: { [weak self] _ in
            self?.hide()
        })
    }
    
    /// Stops the inactivity timer, canceling any pending auto-hide operations.
    private func stopInactivityTimer() {
        inactivityTimerCancellable?.cancel()
        inactivityTimerCancellable = nil
    }
}

// MARK: - Hashable Conformance

extension DMLoadingManagerMain: Hashable {
    
    /// Compares two `DMLoadingManager` instances for equality based on their `id`.
    /// - Parameters:
    ///   - lhs: The left-hand side `DMLoadingManager` instance.
    ///   - rhs: The right-hand side `DMLoadingManager` instance.
    /// - Returns: `true` if the `id` values of both instances are equal; otherwise, `false`.
    nonisolated public static func == (lhs: DMLoadingManagerMain,
                                       rhs: DMLoadingManagerMain) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes the `id` of the `DMLoadingManager` instance into the provided hasher.
    /// - Parameter hasher: The hasher to use for combining the `id`.
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(String.pointer(self))
    }
}
