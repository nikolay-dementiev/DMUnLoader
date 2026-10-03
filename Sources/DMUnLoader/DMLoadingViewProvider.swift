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
    public let loadingManagerSettings: any DMLoadingManagerSettings
    public let loadingViewSettings: any DMProgressViewSettings
    public let errorViewSettings: any DMErrorViewSettings
    public let successViewSettings: any DMSuccessViewSettings
    
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
