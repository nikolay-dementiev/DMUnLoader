//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 28.01.2025.
//

import SwiftUI

/// Protocol for configuring LoadingView
public protocol DMLoadingViewProvider {
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
}

public extension DMLoadingViewProvider {
    @MainActor
    func getLoadingView() -> some View {
        DMProgressView()
    }
    
    @MainActor
    func getErrorView(error: Error,
                             onRetry: (() -> Void)?,
                             onClose: @escaping () -> Void) -> some View {
        DMErrorView(error: error,
                    onRetry: onRetry,
                    onClose: onClose)
    }
    
    @MainActor
    func getSuccessView(message: Any) -> some View {
        DMSuccessView(assosiatedObject: message)
    }
}

/// Default provider implementation
public struct DefaultDMLoadingViewProvider: DMLoadingViewProvider {
    public init() {
        
    }
}
