//
//  DMRootLoadingView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUICore

public struct DMRootLoadingView<Content: View, Provider: DMLoadingViewProvider>: View {
    @StateObject private var loadingManager: DMLoadingManager<Provider>
    
    private let content: (Provider) -> Content
    private let provider: Provider
    
    public init(
        provider: Provider = DefaultDMLoadingViewProvider(),
        @ViewBuilder content: @escaping (Provider) -> Content
    ) {
        _loadingManager = StateObject(wrappedValue: DMLoadingManager(provider: provider))
        self.content = content
        self.provider = provider
    }
    
    public var body: some View {
        return content(provider)
            .environmentObject(loadingManager)
            .autoLoading(loadingManager)
    }
}
