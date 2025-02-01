//
//  LoadingWrapper.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 01.02.2025.
//

import SwiftUI

public struct DMLocalLoadingView<Content: View, Provider: DMLoadingViewProvider>: View {
    private let provider: Provider
    private let content: () -> Content
    
    @StateObject private var loadingManager: DMLoadingManager
    @Environment(\.globalLoadingManager) var globalLoadingManager

    public init(provider: Provider,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.provider = provider
        _loadingManager = StateObject(wrappedValue: DMLoadingManager(state: .none,
                                                                     settings: provider.loadingManagerSettings))
        
        /*
        subscribeToGloabalLoadingManagers(localManager: loadingManager,
                                          globalManager: globalLoadingManager)
        */
    }

    public var body: some View {
        content()
            .autoLoading(loadingManager,
                         provider: provider)
            .onAppear {
                subscribeToGloabalLoadingManagers(localManager: loadingManager,
                                                  globalManager: globalLoadingManager)
            }
    }
}
