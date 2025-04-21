//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A protocol defining the interface for providing views and settings related to loading, error, and success states.
/// Conforming types must also conform to `ObservableObject`, `Identifiable`, and `Hashable`.
public protocol DMLoadingViewProviderProtocol: ObservableObject, Identifiable, Hashable {
    
    /// The type of view used to represent the loading state.
    associatedtype LoadingViewType: View
    
    /// The type of view used to represent the error state.
    associatedtype ErrorViewType: View
    
    /// The type of view used to represent the success state.
    associatedtype SuccessViewType: View
    
    /// A unique identifier for the provider.
    var id: UUID { get }
    
    /// Returns a view representing the loading state.
    /// - Returns: A view conforming to `LoadingViewType`.
    @MainActor
    func getLoadingView() -> LoadingViewType
    
    /// Returns a view representing the error state.
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - onRetry: An optional action to retry the operation.
    ///   - onClose: An action to close the error view.
    /// - Returns: A view conforming to `ErrorViewType`.
    @MainActor
    func getErrorView(error: Error,
                      onRetry: DMAction?,
                      onClose: DMAction) -> ErrorViewType
    
    /// Returns a view representing the success state.
    /// - Parameter object: The success message or object associated with the success state.
    /// - Returns: A view conforming to `SuccessViewType`.
    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType
    
    // MARK: - Settings
    
    /// The settings used by the loading manager.
    var loadingManagerSettings: DMLoadingManagerSettings { get }
    
    /// The settings used to configure the loading view.
    /// - Note: These settings are only used for default implementations of the loading view.
    var loadingViewSettings: DMLoadingViewSettings { get }
    
    /// The settings used to configure the error view.
    /// - Note: These settings are only used for default implementations of the error view.
    var errorViewSettings: DMErrorViewSettings { get }
    
    /// The settings used to configure the success view.
    /// - Note: These settings are only used for default implementations of the success view.
    var successViewSettings: DMSuccessViewSettings { get }
}

/// Default implementations for `DMLoadingViewProviderProtocol`.
public extension DMLoadingViewProviderProtocol {
    
    /// Returns a default loading view using the provided `loadingViewSettings`.
    /// - Returns: A `DMProgressView` configured with the `loadingViewSettings`.
    /// - Example:
    ///   ```swift
    ///   let provider = DefaultDMLoadingViewProvider()
    ///   let loadingView = provider.getLoadingView()
    ///   ```
    @MainActor
    func getLoadingView() -> some View {
        DMProgressView(settings: loadingViewSettings)
    }
    
    /// Returns a default error view using the provided `errorViewSettings`.
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - onRetry: An optional action to retry the operation.
    ///   - onClose: An action to close the error view.
    /// - Returns: A `DMErrorView` configured with the `errorViewSettings`.
    /// - Example:
    ///   ```swift
    ///   let provider = DefaultDMLoadingViewProvider()
    ///   let errorView = provider.getErrorView(
    ///       error: NSError(domain: "Example", code: 404),
    ///       onRetry: DMAction(title: "Retry") {},
    ///       onClose: DMAction(title: "Close") {}
    ///   )
    ///   ```
    @MainActor
    func getErrorView(error: Error,
                      onRetry: DMAction?,
                      onClose: DMAction) -> some View {
        DMErrorView(settings: errorViewSettings,
                    error: error,
                    onRetry: onRetry,
                    onClose: onClose)
    }
    
    /// Returns a default success view using the provided `successViewSettings`.
    /// - Parameter object: The success message or object associated with the success state.
    /// - Returns: A `DMSuccessView` configured with the `successViewSettings`.
    /// - Example:
    ///   ```swift
    ///   let provider = DefaultDMLoadingViewProvider()
    ///   let successView = provider.getSuccessView(object: "Operation Completed!")
    ///   ```
    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
        DMSuccessView(settings: successViewSettings,
                      assosiatedObject: object)
    }
    
    // MARK: - Default Settings
    
    /// Provides default settings for the loading manager.
    /// - Returns: An instance of `DMLoadingManagerDefaultSettings`.
    var loadingManagerSettings: DMLoadingManagerSettings {
        DMLoadingManagerDefaultSettings()
    }
    
    /// Provides default settings for the loading view.
    /// - Returns: An instance of `DMLoadingDefaultViewSettings`.
    var loadingViewSettings: DMLoadingViewSettings {
        DMLoadingDefaultViewSettings()
    }
    
    /// Provides default settings for the error view.
    /// - Returns: An instance of `DMErrorDefaultViewSettings`.
    var errorViewSettings: DMErrorViewSettings {
        DMErrorDefaultViewSettings()
    }
    
    /// Provides default settings for the success view.
    /// - Returns: An instance of `DMSuccessDefaultViewSettings`.
    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings()
    }
}

/// Conformance to `Hashable` for `DMLoadingViewProviderProtocol`.
extension DMLoadingViewProviderProtocol {
    
    /// Compares two instances of `DMLoadingViewProviderProtocol` for equality based on their `id`.
    /// - Parameters:
    ///   - lhs: The left-hand side instance.
    ///   - rhs: The right-hand side instance.
    /// - Returns: `true` if the `id` values of both instances are equal; otherwise, `false`.
    nonisolated public static func == (lhs: Self,
                                       rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes the `id` of the provider into the provided hasher.
    /// - Parameter hasher: The hasher to use for combining the `id`.
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// A default implementation of `DMLoadingViewProviderProtocol`.
/// This class provides default views and settings for loading, error, and success states.
public final class DefaultDMLoadingViewProvider: DMLoadingViewProviderProtocol {
    
    /// A unique identifier for the provider.
    public var id: UUID
    
    /// Initializes a new instance of `DefaultDMLoadingViewProvider`.
    public init() {
        self.id = UUID()
    }
}
