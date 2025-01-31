//
//  DMLoadingModifier.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUICore

/// Modifier to add LoadingView to any View
internal struct DMLoadingModifier<Provider: DMLoadingViewProvider>: ViewModifier {
    @ObservedObject internal var loadingManager: DMLoadingManager
    
    internal var provider: Provider
    
    public func body(content: Content) -> some View {
        let isLoading = loadingManager.loadableState != .none
        
        return ZStack {
            content
                .blur(radius: isLoading ? 2 : 0)
                .disabled(isLoading)
            
            DMLoadingView(loadingManager: loadingManager,
                          provider: provider)
        }
    }
}

internal struct DMRootLoadingModifier: ViewModifier {
    public func body(content: Content) -> some View {
        return ZStack {
            content
            
            BlockingView()
                .allowsHitTesting(true)
        }
    }
}

private struct BlockingView: View {
    var body: some View {
        Color.gray.opacity(0.001)
            .ignoresSafeArea()
    }
}
