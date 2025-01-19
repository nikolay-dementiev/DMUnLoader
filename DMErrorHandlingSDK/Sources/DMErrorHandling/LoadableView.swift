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

//public struct LoadableView<T, U: View>: View {
public struct LoadableView<T>: View {
    let element: Loadable<T>
//    @ViewBuilder let onSuccess: (T) -> U
//    let onRetry: (() -> Void)?
    
    public let loadingViewScene: LoadingViewScene = DMNativeProgressView()
    
    //    @State private var isLoading: Bool = true
    
    public var body: some View {
        
//        let isLoading: Bool = { if case .loading = element { return true } else { return false }}()
        let isLoading = true
        self
            .disabled(isLoading)
            .blur(radius: isLoading ? 3 : 0)
        
        switch element {
        case .loading:
            loadingViewScene.getLoadingView()
        default:
            fatalError()
            
//        case .failure(let error): ErrorView(error: error, onRetry: onRetry)
//        case .success(let value): onSuccess(value)
        }
    }
}

#Preview {
//    let successBlock: (Any) -> AnyView = { _ in
//        AnyView(EmptyView())
//    }
    LoadableView<Loadable<Any>>(element: .loading)
}
