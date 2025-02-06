//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 01.02.2025.
//

import SwiftUICore

internal struct DMRootLoadingModifier: ViewModifier {
    @ObservedObject var globalLoadingStateManager: GlobalLoadingStateManager
    
    public func body(content: Content) -> some View {
        return ZStack {
            content
            
            if globalLoadingStateManager.isLoading {
                BlockingView()
                    .allowsHitTesting(true)
            }
        }
    }
}

private struct BlockingView: View {
    var body: some View {
        Color.gray.opacity(0.001)
            .ignoresSafeArea()
    }
}
