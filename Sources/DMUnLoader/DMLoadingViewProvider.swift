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
    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> ErrorViewType
    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType

    var loadingManagerSettings: DMLoadingManagerSettings { get }
    var loadingViewSettings: DMProgressViewSettings { get }
    var errorViewSettings: DMErrorViewSettings { get }
    var successViewSettings: DMSuccessViewSettings { get }
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
    func getErrorView(error: Error,
                      onRetry: DMAction?,
                      onClose: DMAction) -> some View {
        DMErrorView(settings: errorViewSettings,
                    error: error,
                    onRetry: onRetry,
                    onClose: onClose)
    }
    
    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
        DMSuccessView(settings: successViewSettings,
                      assosiatedObject: object)
    }
    
    // MARK: - Default Settings
    
    var loadingManagerSettings: DMLoadingManagerSettings {
        DMLoadingManagerDefaultSettings()
    }
    
    var loadingViewSettings: DMProgressViewSettings {
        DMProgressViewDefaultSettings()
    }
    
    var errorViewSettings: DMErrorViewSettings {
        DMErrorDefaultViewSettings()
    }
    
    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings()
    }
}

public class DefaultDMLoadingViewProvider: @MainActor DMLoadingViewProvider {
    public let loadingManagerSettings: DMLoadingManagerSettings
    public let loadingViewSettings: DMProgressViewSettings
    public let errorViewSettings: DMErrorViewSettings
    public let successViewSettings: DMSuccessViewSettings
    
    public init(
        loadingManagerSettings: DMLoadingManagerSettings? = nil,
        loadingViewSettings: DMProgressViewSettings? = nil,
        errorViewSettings: DMErrorViewSettings? = nil,
        successViewSettings: DMSuccessViewSettings? = nil
    ) {
        self.loadingManagerSettings = loadingManagerSettings ?? DMLoadingManagerDefaultSettings()
        self.loadingViewSettings = loadingViewSettings ?? DMProgressViewDefaultSettings()
        self.errorViewSettings = errorViewSettings ?? DMErrorDefaultViewSettings()
        self.successViewSettings = successViewSettings ?? DMSuccessDefaultViewSettings()
    }
}
