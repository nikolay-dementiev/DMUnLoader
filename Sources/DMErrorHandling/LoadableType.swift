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

public enum LoadableType: Hashable, RawRepresentable {
    public typealias RawValue = String
    
    case loading
    case failure(error: Error, onRetry: (() -> Void)? = nil)
    case success(Any) //TODO: need to wrap into some protocol to omit casting from Any
    case none
    
    public var rawValue: RawValue {
        let rawValueForReturn: RawValue
        switch self {
        case .loading:
            rawValueForReturn = "Loading"
        case .failure(let error, _):
            rawValueForReturn = "Error: \(error)"
        case .success(let message):
            rawValueForReturn = "Success: \(message)"
        case .none:
            rawValueForReturn = "None"
        }
        
        return rawValueForReturn
    }
    
    public init?(rawValue: RawValue) {
        nil
    }
    
    public static func == (lhs: LoadableType,
                           rhs: LoadableType) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

//public struct LoadableView<T, U: View>: View {
//    //public struct LoadableView<T>: View {
//    let element: Loadable<T>
//    @ViewBuilder let onSuccess: (T) -> U
//    let onRetry: (() -> Void)?

//DMProgressLoadingView<Content>: View, LoadingViewScene where Content: View


/*
public struct LoadableView<Content: View>: View {
    //static let shared: LoadableView = LoadableView()
    
    //public struct LoadableView<T>: View {
    @Binding internal var type: LoadableType
//    @ViewBuilder let onSuccess: (Any) -> Void
//    let onSuccess: (Any) -> Void
    
//    let onRetry: (() -> Void)?
    
    private let content: () -> Content
    
    public let loadingViewScene: LoadingViewScene = DMNativeProgressView()
    
    //    @State private var isLoading: Bool = true
    
    //@MainActor
    public init(type: Binding<LoadableType>,
                @ViewBuilder content: @escaping () -> Content) {
        self._type = type
        self.content = content
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
            self.content()
                .disabled(isLoading)
                .blur(radius: isLoading ? 3 : 0)
            
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
 */

//#Preview {
////    LoadableView<Loadable<Float>>(element: .loading)
////    let successBlock: (Any) -> Void = { _ in print("success") }
////    
////    LoadableView(element: .loading,
////                 onSuccess: successBlock)
//    LoadableView(type: .loading) {
//        List(["1", "2", "3", "4", "5"], id: \.self) { row in
//            Text(row)
//        }.navigationBarTitle(Text("A List"), displayMode: .large)
//    }
//}
