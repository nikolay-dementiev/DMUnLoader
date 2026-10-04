//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

public protocol DMLoadingViewProvider: ObservableObject, Hashable {
    associatedtype LoadingViewType: View
    associatedtype ErrorViewType: View
    associatedtype SuccessViewType: View
    
    @MainActor
    func getLoadingView() -> LoadingViewType
    @MainActor
    func getErrorView(error: any Error, onRetry: (any DMAction)?, onClose: any DMAction) -> ErrorViewType
    @MainActor
    func getSuccessView(object: any DMLoadableTypeSuccess) -> SuccessViewType

    /// Loading manager settings carried by the provider. The library does not read them: a
    /// success or a failure hides after the `settings.autoHideDelay` of the loading manager
    /// that shows it, whatever provider it was shown with. `eraseToAnyViewProvider()` passes
    /// the value on unchanged.
    var loadingManagerSettings: any DMLoadingManagerSettings { get }
    var loadingViewSettings: any DMProgressViewSettings { get }
    var errorViewSettings: any DMErrorViewSettings { get }
    var successViewSettings: any DMSuccessViewSettings { get }
}

extension DMLoadingViewProvider {
    /// Compares two providers by identity: a provider is equal only to itself, whatever its
    /// hash.
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        lhs === rhs
    }

    /// Hashes the identity of the provider into the provided hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public extension DMLoadingViewProvider {
    
    @MainActor
    func getLoadingView() -> some View {
        DMProgressView(settings: loadingViewSettings)
    }
    
    @MainActor
    func getErrorView(error: any Error,
                      onRetry: (any DMAction)?,
                      onClose: any DMAction) -> some View {
        DMErrorView(settings: errorViewSettings,
                    error: error,
                    onRetry: onRetry,
                    onClose: onClose)
    }
    
    @MainActor
    func getSuccessView(object: any DMLoadableTypeSuccess) -> some View {
        DMSuccessView(settings: successViewSettings,
                      assosiatedObject: object)
    }
    
    // MARK: - Default Settings

    /// Settings with an auto-hide delay of 2 seconds. Not read by the library: the loading
    /// manager's own settings decide the delay.
    var loadingManagerSettings: any DMLoadingManagerSettings {
        DMLoadingManagerDefaultSettings()
    }
    
    var loadingViewSettings: any DMProgressViewSettings {
        DMProgressViewDefaultSettings()
    }
    
    var errorViewSettings: any DMErrorViewSettings {
        DMErrorDefaultViewSettings()
    }
    
    var successViewSettings: any DMSuccessViewSettings {
        DMSuccessDefaultViewSettings()
    }
}

public class DefaultDMLoadingViewProvider: @MainActor DMLoadingViewProvider {
    /// The settings passed to the initializer, or settings with a 2-second delay. Not read by
    /// the library: the loading manager's own settings decide the delay.
    public let loadingManagerSettings: any DMLoadingManagerSettings
    public let loadingViewSettings: any DMProgressViewSettings
    public let errorViewSettings: any DMErrorViewSettings
    public let successViewSettings: any DMSuccessViewSettings

    /// Creates a provider of the default loading, error and success views.
    /// - Parameters:
    ///   - loadingManagerSettings: Kept as `loadingManagerSettings` and not read by the
    ///     library; set the delay on the loading manager, `DMLoadingManagerMain(state:settings:)`.
    ///     Defaults to settings with a 2-second delay.
    ///   - loadingViewSettings: Settings of the loading view. Defaults to `DMProgressViewDefaultSettings()`.
    ///   - errorViewSettings: Settings of the error view. Defaults to `DMErrorDefaultViewSettings()`.
    ///   - successViewSettings: Settings of the success view. Defaults to `DMSuccessDefaultViewSettings()`.
    public init(
        loadingManagerSettings: (any DMLoadingManagerSettings)? = nil,
        loadingViewSettings: (any DMProgressViewSettings)? = nil,
        errorViewSettings: (any DMErrorViewSettings)? = nil,
        successViewSettings: (any DMSuccessViewSettings)? = nil
    ) {
        self.loadingManagerSettings = loadingManagerSettings ?? DMLoadingManagerDefaultSettings()
        self.loadingViewSettings = loadingViewSettings ?? DMProgressViewDefaultSettings()
        self.errorViewSettings = errorViewSettings ?? DMErrorDefaultViewSettings()
        self.successViewSettings = successViewSettings ?? DMSuccessDefaultViewSettings()
    }
}
