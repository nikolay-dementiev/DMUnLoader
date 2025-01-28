//
//  LoadingModifier.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUICore

// Modifier to add LoadingView to any View
public struct LoadingModifier<Provider: LoadingViewProvider>: ViewModifier {
    @ObservedObject internal var loadingManager: LoadingManager<Provider>
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: loadingManager.loadableState == .none ? 0 : 2)
                .disabled(loadingManager.loadableState != .none)
            
            LoadingView(loadingManager: loadingManager)
        }
    }
}


//internal struct SizeCalculator: ViewModifier {
//    
//    @Binding var size: CGSize
//    
//    func body(content: Content) -> some View {
//        content
//            .background(
//                GeometryReader { proxy in
//                    Color.clear // we just want the reader to get triggered, so let's use an empty color
//                        .onAppear {
//                            size = proxy.size
//                        }
//                }
//            )
//    }
//}
//
//internal extension View {
//    func saveSize(in size: Binding<CGSize>) -> some View {
//        modifier(SizeCalculator(size: size))
//    }
//}
