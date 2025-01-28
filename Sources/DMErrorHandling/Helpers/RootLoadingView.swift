//
//  RootLoadingView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUICore

public struct RootLoadingView<Content: View, Provider: LoadingViewProvider>: View {
    @StateObject private var loadingManager: LoadingManager<Provider>
    
    private let content: (Provider) -> Content
    private let provider: Provider
    
    public init(
        provider: Provider = DefaultLoadingViewProvider(),
        @ViewBuilder content: @escaping (Provider) -> Content
    ) {
        _loadingManager = StateObject(wrappedValue: LoadingManager(provider: provider))
        self.content = content
        self.provider = provider
    }
    
    public var body: some View {
//        GeometryReader { proxy in
//            self
//                .environment(\.mainWindowSize, proxy.size)
//        }
        
        return content(provider)
            .environmentObject(loadingManager)
            .autoLoading(loadingManager) // Автоматичне додавання оверлею
    }
}
