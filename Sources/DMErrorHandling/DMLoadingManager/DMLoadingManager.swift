//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation
import Combine

/// A `ViewModel` responsible for managing and handling loading states in a user interface.
/// This class conforms to `DMLoadingManagerInteralProtocol` and provides functionality to
/// show loading, success, failure, and hidden states, as well as manage an inactivity timer.
@MainActor
public final class DMLoadingManager: DMLoadingManagerInteralProtocol {
    
    /// A unique identifier for the loading manager.
    public let id: UUID
    
    /// The settings used by the loading manager to configure its behavior, such as auto-hide delay.
    public let settings: DMLoadingManagerSettings
    
    /// A `PassthroughSubject` used to emit changes to the `loadableState`.
    private let loadableStateSubject = PassthroughSubject<DMLoadableType, Never>()
    
    /// The current loadable state of the manager (e.g., `.none`, `.loading`, `.success`, `.failure`).
    /// - Note: This property is thread-safe and emits changes via `loadableStateSubject`.
    @Published internal(set) public var loadableState: DMLoadableType = .none {
        willSet {
            loadableStateSubject.send(newValue)
        }
    }
    
    /// A publisher that emits changes to the `loadableState`.
    /// - Note: This property enables reactive programming using Combine, allowing observers
    ///   to react to state changes in real-time.
    /// - Example:
    ///   ```swift
    ///   cancellable = loadingManager.loadableStatePublisher.sink { state in
    ///       print("Loadable state changed to: \(state)")
    ///   }
    ///   ```
    internal var loadableStatePublisher: AnyPublisher<DMLoadableType, Never> {
        loadableStateSubject.eraseToAnyPublisher()
    }
    
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
    public init(id: UUID = UUID(),
                state loadableState: DMLoadableType,
                settings: DMLoadingManagerSettings) {
        self.id = id
        self.loadableState = loadableState
        self.settings = settings
    }
    
    /// Shows the loading state, typically indicating that an operation is in progress.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showLoading()
    ///   ```
    public func showLoading() {
        stopInactivityTimer()
        
        loadableState = .loading
    }
    
    /// Shows the success state with a success message.
    /// - Parameter message: A value conforming to `DMLoadableTypeSuccess`, representing the success message.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showSuccess("Data loaded successfully")
    ///   ```
    public func showSuccess(_ message: DMLoadableTypeSuccess) {
        startInactivityTimer()
        
        loadableState = .success(message)
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
    public func showFailure(_ error: Error, onRetry: DMAction? = nil) {
        startInactivityTimer()
        
        loadableState = .failure(error: error, onRetry: onRetry)
    }
    
    /// Hides the loading state, resetting it to `.none`.
    /// - Example:
    ///   ```swift
    ///   loadingManager.hide()
    ///   ```
    public func hide() {
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

extension DMLoadingManager: Hashable {
    
    /// Compares two `DMLoadingManager` instances for equality based on their `id`.
    /// - Parameters:
    ///   - lhs: The left-hand side `DMLoadingManager` instance.
    ///   - rhs: The right-hand side `DMLoadingManager` instance.
    /// - Returns: `true` if the `id` values of both instances are equal; otherwise, `false`.
    nonisolated public static func == (lhs: DMLoadingManager,
                                       rhs: DMLoadingManager) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes the `id` of the `DMLoadingManager` instance into the provided hasher.
    /// - Parameter hasher: The hasher to use for combining the `id`.
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
