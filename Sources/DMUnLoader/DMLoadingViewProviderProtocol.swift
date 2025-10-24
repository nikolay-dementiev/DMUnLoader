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
    var loadingViewSettings: DMLoadingViewSettings { get }
    var errorViewSettings: DMErrorViewSettings { get }
    var successViewSettings: DMSuccessViewSettings { get }
}

extension DMLoadingViewProvider {
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String.pointer(self))
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
    
    var loadingViewSettings: DMLoadingViewSettings {
        DMLoadingDefaultViewSettings()
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
    public let loadingViewSettings: DMLoadingViewSettings
    public let errorViewSettings: DMErrorViewSettings
    public let successViewSettings: DMSuccessViewSettings
    
    public init(
        loadingManagerSettings: DMLoadingManagerSettings? = nil,
        loadingViewSettings: DMLoadingViewSettings? = nil,
        errorViewSettings: DMErrorViewSettings? = nil,
        successViewSettings: DMSuccessViewSettings? = nil
    ) {
        self.loadingManagerSettings = loadingManagerSettings ?? DMLoadingManagerDefaultSettings()
        self.loadingViewSettings = loadingViewSettings ?? DMLoadingDefaultViewSettings()
        self.errorViewSettings = errorViewSettings ?? DMErrorDefaultViewSettings()
        self.successViewSettings = successViewSettings ?? DMSuccessDefaultViewSettings()
    }
}
