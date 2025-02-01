//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 28.01.2025.
//

import SwiftUI

/// Protocol for configuring LoadingView
public protocol DMLoadingViewProvider: ObservableObject {
    associatedtype LoadingViewType: View
    associatedtype ErrorViewType: View
    associatedtype SuccessViewType: View
    
    @MainActor
    func getLoadingView() -> LoadingViewType
    @MainActor
    func getErrorView(error: Error,
                      onRetry: (() -> Void)?,
                      onClose: @escaping () -> Void) -> ErrorViewType
    @MainActor
    func getSuccessView(message: Any) -> SuccessViewType
    
    //Settings
    var loadingManagerSettings: DMLoadingManagerSettings { get }
    
    //Next settings are uses only for default screens!
    var loadingViewSettings: DMLoadingViewSettings { get }
    var errorViewSettings: DMErrorViewSettings { get }
    var successViewSettings: DMSuccessViewSettings { get }
}

public extension DMLoadingViewProvider {
    @MainActor
    func getLoadingView() -> some View {
        DMProgressView(settings: loadingViewSettings)
    }
    
    @MainActor
    func getErrorView(error: Error,
                      onRetry: (() -> Void)?,
                      onClose: @escaping () -> Void) -> some View {
        DMErrorView(settings: errorViewSettings,
                    error: error,
                    onRetry: onRetry,
                    onClose: onClose)
    }
    
    @MainActor
    func getSuccessView(message: Any) -> some View {
        DMSuccessView(settings: successViewSettings,
                      assosiatedObject: message)
    }
    
    //Settings
    
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

/// Default provider implementation
public final class DefaultDMLoadingViewProvider: DMLoadingViewProvider {
    public init() {
        
    }
}
