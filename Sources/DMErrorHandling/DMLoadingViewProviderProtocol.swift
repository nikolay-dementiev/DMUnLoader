//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMAction

/// Protocol for configuring LoadingView
public protocol DMLoadingViewProviderProtocol: ObservableObject, Identifiable, Hashable {
    associatedtype LoadingViewType: View
    associatedtype ErrorViewType: View
    associatedtype SuccessViewType: View
    
    var id: UUID { get }
    
    @MainActor
    func getLoadingView() -> LoadingViewType
    @MainActor
    func getErrorView(error: Error,
                      onRetry: DMAction?,
                      onClose: DMAction) -> ErrorViewType
    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType
    
    // Settings
    var loadingManagerSettings: DMLoadingManagerSettings { get }
    
    // Next settings are uses only for default screens!
    var loadingViewSettings: DMLoadingViewSettings { get }
    var errorViewSettings: DMErrorViewSettings { get }
    var successViewSettings: DMSuccessViewSettings { get }
}

public extension DMLoadingViewProviderProtocol {
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
    
    // Settings
    
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

extension DMLoadingViewProviderProtocol {
    nonisolated public static func == (lhs: Self,
                                       rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Default provider implementation
public final class DefaultDMLoadingViewProvider: DMLoadingViewProviderProtocol {
    public var id: UUID
    
    public init() {
        self.id = UUID()
    }
}
