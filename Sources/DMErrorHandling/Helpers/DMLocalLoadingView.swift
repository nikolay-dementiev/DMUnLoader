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
    
    @StateObject internal var loadingManager: DMLoadingManager
    @Environment(\.globalLoadingManager) internal var globalLoadingManager
    
    //uses for UIKit's approach to obtain Loading Manager object
    private(set) internal var getLoadingManager: () -> DMLoadingManager

    public init(provider: Provider,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.provider = provider
        let newLoadingManager = DMLoadingManager(state: .none,
                                                 settings: provider.loadingManagerSettings)
        self.getLoadingManager = {
            newLoadingManager
        }
        
        _loadingManager = StateObject(wrappedValue: newLoadingManager)
    }

    public var body: some View {
        content()
            .autoLoading(loadingManager,
                         provider: provider)
            .onAppear {
                subscribeToGloabalLoadingManagers(localManager: loadingManager,
                                                  globalManager: globalLoadingManager)
            }
            .onDisappear {
                unsubscribeFromLoadingManager(localManager: loadingManager,
                                              globalManager: globalLoadingManager)
            }
    }
}
