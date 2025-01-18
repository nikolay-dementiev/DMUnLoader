//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 16.01.2025.
//

import SwiftUI

public enum Loadable<Value> {
    case loading
    case failure(error: Error)
    case success(Value)
}

public struct LoadableView<T, U: View>: View {
    let element: Loadable<T>
    @ViewBuilder let onSuccess: (T) -> U
    let onRetry: (() -> Void)?
    
    public let loadingViewScene: LoadingViewScene = NativeProgressView()
    
    @State private var isLoading: Bool = true
    
    public var body: some View {
        self
            .disabled(self.isLoading)
            .blur(radius: self.isLoading ? 3 : 0)
        
        switch element {
        case .loading: loadingViewScene.getLoadingView()//LoadingView()//LoadingView(sceneDelegate: DMProgressLoadingView(isShowing: $isLoading, content: { self }))
        case .failure(let error): ErrorView(error: error, onRetry: onRetry)
        case .success(let value): onSuccess(value)
        }
    }
}
