//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//
import Foundation
import Combine

/// A protocol defining the public interface for a loading manager.
/// Conforming types must also conform to `ObservableObject`.
///
/// This protocol is used to manage and display loading states (e.g., loading, success, failure)
/// in a user interface. It provides methods to show or hide these states and supports
/// optional retry actions for failure states.
@MainActor
public protocol DMLoadingManager: ObservableObject {
    
    /// The current loadable state of the manager (e.g., `.none`, `.loading`, `.success`, `.failure`).
    /// - Note: This property is mutable and allows the manager to update its state dynamically.
    var loadableState: DMLoadableType { get }
    
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
    func showLoading<PR: DMLoadingViewProvider>(provider: PR)
    
    /// Shows the success state with a success message.
    /// - Parameter message: A value conforming to `DMLoadableTypeSuccess`, representing the success message.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showSuccess("Data loaded successfully")
    ///   ```
    func showSuccess<PR: DMLoadingViewProvider>(_ message: DMLoadableTypeSuccess, provider: PR)
    
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
    func showFailure<PR: DMLoadingViewProvider>(_ error: Error, provider: PR, onRetry: DMAction?)
    
    /// Hides the loading state, resetting it to `.none`.
    /// - Example:
    ///   ```swift
    ///   loadingManager.hide()
    ///   ```
    func hide()
    
    init()
}
