//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//
import Foundation
import Combine

/// A protocol defining the public interface for a loading manager.
/// Conforming types must also conform to `Identifiable` and `ObservableObject`.
///
/// This protocol is used to manage and display loading states (e.g., loading, success, failure)
/// in a user interface. It provides methods to show or hide these states and supports
/// optional retry actions for failure states.
@MainActor
public protocol DMLoadingManagerProtocol: Identifiable, ObservableObject {
    
    /// A unique identifier for the loading manager.
    /// - Note: This property is required by the `Identifiable` protocol.
    var id: UUID { get }
    
    /// The settings used by the loading manager to configure its behavior.
    /// - Example:
    ///   ```swift
    ///   let settings = DMLoadingManagerSettings(autoHideDelay: 10)
    ///   ```
    var settings: DMLoadingManagerSettings { get }
    
    /// Shows the loading state, typically indicating that an operation is in progress.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showLoading()
    ///   ```
    func showLoading()
    
    /// Shows the success state with a success message.
    /// - Parameter message: A value conforming to `DMLoadableTypeSuccess`, representing the success message.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showSuccess("Data loaded successfully")
    ///   ```
    func showSuccess(_ message: DMLoadableTypeSuccess)
    
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
    func showFailure(_ error: Error, onRetry: DMAction?)
    
    /// Hides the loading state, resetting it to `.none`.
    /// - Example:
    ///   ```swift
    ///   loadingManager.hide()
    ///   ```
    func hide()
}

/// An internal protocol extending `DMLoadingManagerProtocol` to include additional properties
/// and functionality required for internal implementation.
///
/// This protocol is intended for use within the module and should not be exposed publicly.
@MainActor
internal protocol DMLoadingManagerInteralProtocol: DMLoadingManagerProtocol {
    
    /// The current loadable state of the manager (e.g., `.none`, `.loading`, `.success`, `.failure`).
    /// - Note: This property is mutable and allows the manager to update its state dynamically.
    var loadableState: DMLoadableType { get set }
    
    /// A publisher that emits changes to the `loadableState`.
    /// - Note: This property enables reactive programming using Combine, allowing observers
    ///   to react to state changes in real-time.
    /// - Example:
    ///   ```swift
    ///   cancellable = loadingManager.loadableStatePublisher.sink { state in
    ///       print("Loadable state changed to: \(state)")
    ///   }
    ///   ```
    var loadableStatePublisher: AnyPublisher<DMLoadableType, Never> { get }
}
