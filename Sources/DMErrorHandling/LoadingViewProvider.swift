//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 28.01.2025.
//

import SwiftUI

// Протокол для налаштування LoadingView
public protocol LoadingViewProvider {
    associatedtype LoadingViewType: View
    associatedtype ErrorViewType: View
    associatedtype SuccessViewType: View
    
    @MainActor
    func getLoadingView() -> LoadingViewType
    @MainActor
    func getErrorView(error: Error, onRetry: (() -> Void)?) -> ErrorViewType
    @MainActor
    func getSuccessView(message: Any) -> SuccessViewType
}

// Реалізація провайдера за замовчуванням
public struct DefaultLoadingViewProvider: LoadingViewProvider {
    public init() {
        
    }
    
    @MainActor
    public func getLoadingView() -> some View {
        DMNativeProgressView()
    }
    
    @MainActor
    public func getErrorView(error: Error, onRetry: (() -> Void)?) -> some View {
        ErrorView(error: error, onRetry: onRetry)
    }
    
    @MainActor
    public func getSuccessView(message: Any) -> some View {
        SuccessView(assosiatedObject: message)
    }
}
