//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 16.01.2025.
//

import SwiftUI

//public enum Loadable<Value> {
//    case loading
//    case failure(error: Error)
//    case success(Value)
//}

public enum LoadableType {
    case loading
    case failure(error: Error, onRetry: (() -> Void)? = nil)
    case success(Any) //TODO: need to wrap into some protocol to omit caseting from Any
}

//public struct LoadableView<T, U: View>: View {
//    //public struct LoadableView<T>: View {
//    let element: Loadable<T>
//    @ViewBuilder let onSuccess: (T) -> U
//    let onRetry: (() -> Void)?

//DMProgressLoadingView<Content>: View, LoadingViewScene where Content: View

public struct LoadableView: View {
    //public struct LoadableView<T>: View {
    let type: LoadableType
//    @ViewBuilder let onSuccess: (Any) -> Void
//    let onSuccess: (Any) -> Void
    
//    let onRetry: (() -> Void)?
    
//    let content: () -> Content
    
    public let loadingViewScene: LoadingViewScene = DMNativeProgressView()
    
    //    @State private var isLoading: Bool = true
    
    //@MainActor
    public init(type: LoadableType) {
        self.type = type
    }
    
    public init() {
        self.type = .loading
    }
    
    public var body: some View {
        ZStack {
            let isLoading: Bool = { if case .loading = type { return true } else { return false }}()
            /*
             NavigationView {
             List(["1", "2", "3", "4", "5"], id: \.self) { row in
             Text(row)
             }.navigationBarTitle(Text("A List"), displayMode: .large)
             }
             */
            Color(.clear)
                .disabled(isLoading)
                .blur(radius: isLoading ? 3 : 0)
                .ignoresSafeArea()
            
            switch type {
            case .loading:
                loadingViewScene.getLoadingView()
            case .failure(let error, let action): ErrorView(error: error, onRetry: action)
            case .success(let value):
                //onSuccess(value)
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        
    }
}

#Preview {
//    LoadableView<Loadable<Float>>(element: .loading)
//    let successBlock: (Any) -> Void = { _ in print("success") }
//    
//    LoadableView(element: .loading,
//                 onSuccess: successBlock)
    LoadableView(type: .loading)
}
