//
//  SwiftUIView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 16.01.2025.
//

import SwiftUI

///This protocol provide various loadingView that can uses for LoadingView
///check for detail: https://stackoverflow.com/a/65585090/6643923
@MainActor
public protocol LoadingViewScene {
    func getLoadingView() -> AnyView
}

public extension LoadingViewScene where Self: View {
    func getLoadingView() -> AnyView {
        AnyView(self)
    }
}

//internal struct LoadingView: View {
//    
//    internal var sceneDelegate: LoadingViewScene = NativeProgressView()
//    @State private(set) var isLoading: Bool = true
//    
////    internal init(sceneDelegate: LoadingViewScene = NativeProgressView()) {
////        self.sceneDelegate = sceneDelegate
////    }
//    
//    public var body: some View {
//        sceneDelegate.getLoadingView()
//    }
//}
//
////#Preview {
////    LoadingView()
////}
//
//#Preview {
//    var loadingView = LoadingView()
////    let progressLoadingView = DMProgressLoadingView(isShowing: .constant(true),
////                                                    content: { loadingView })
////    
//////    loadingView.sceneDelegate = progressLoadingView
////   
////    return progressLoadingView
//    return loadingView
//}
