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
    
    /// The state the HUD shows: `.none`, `.loading`, `.success` or `.failure`.
    ///
    /// The HUD observes the manager as an `ObservableObject`, so a manager of your own sends
    /// `objectWillChange` before each change of this state, as a `@Published` property does.
    var loadableState: DMLoadableType { get }
    
    /// The settings of the manager. `DMLoadingManagerMain` hides a success or a failure as these
    /// settings say, by default once `settings.autoHideDelay` has passed; the settings of a view
    /// provider do not change it.
    var settings: any DMLoadingManagerSettings { get }
    
    /// Shows the loading state, typically indicating that an operation is in progress.
    /// - Parameter provider: The provider of the loading view.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showLoading(provider: DefaultDMLoadingViewProvider())
    ///   ```
    func showLoading<PR: DMLoadingViewProvider>(provider: PR)
    
    /// Shows the success state with a success message.
    /// - Parameters:
    ///   - message: A value conforming to `DMLoadableTypeSuccess`, representing the success message.
    ///   - provider: The provider of the success view.
    /// - Example:
    ///   ```swift
    ///   loadingManager.showSuccess("Data loaded successfully", provider: DefaultDMLoadingViewProvider())
    ///   ```
    func showSuccess<PR: DMLoadingViewProvider>(_ message: any DMLoadableTypeSuccess, provider: PR)
    
    /// Shows the failure state with an error and an optional retry action.
    /// - Parameters:
    ///   - error: The error that occurred during the operation.
    ///   - provider: The provider of the error view.
    ///   - onRetry: An optional action (`DMAction`) to retry the operation. The default error
    ///     view shows a Retry button for it.
    /// - Example:
    ///   ```swift
    ///   let retryAction = DMButtonAction {
    ///       // Retry logic here
    ///   }
    ///   loadingManager.showFailure(
    ///       NSError(domain: "Example", code: 404),
    ///       provider: DefaultDMLoadingViewProvider(),
    ///       onRetry: retryAction
    ///   )
    ///   ```
    func showFailure<PR: DMLoadingViewProvider>(_ error: any Error, provider: PR, onRetry: (any DMAction)?)
    
    /// Hides the loading state, resetting it to `.none`.
    /// - Example:
    ///   ```swift
    ///   loadingManager.hide()
    ///   ```
    func hide()
    
    /// Creates a manager with no state shown and its default settings. `DMRootLoadingView`'s
    /// released initializers and the UIKit scene delegate create their manager with it.
    init()
}

extension DMLoadingManager {

    /// Shows a failure without a Retry button: the same as
    /// `showFailure(error, provider: provider, onRetry: nil)`.
    ///
    /// `DMLoadingManagerMain` already accepts this call through the default value of its
    /// `onRetry` parameter, and keeps using its own method. This method makes the call compile
    /// for every loading manager: a generic `LM`, `any DMLoadingManager`, or a manager of the
    /// host's own.
    public func showFailure<PR: DMLoadingViewProvider>(_ error: any Error, provider: PR) {
        showFailure(error, provider: provider, onRetry: nil)
    }
}
