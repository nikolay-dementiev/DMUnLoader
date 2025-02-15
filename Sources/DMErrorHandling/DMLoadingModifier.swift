//
//  DMLoadingModifier.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUICore
import Combine

/// Modifier to add LoadingView to any View
internal struct DMLoadingModifier<Provider: DMLoadingViewProviderProtocol,
                                  LLM: DMLoadingManagerInteralProtocol>: ViewModifier {
 #if DEBUG
    internal let inspection: Inspection<Self>? = getInspectionIfAvailable()
 #endif
    
    @ObservedObject internal var loadingManager: LLM
    internal var provider: Provider
    
    internal func body(content: Content) -> some View {
        let isLoading = loadingManager.loadableState != .none
        
        return ZStack {
            content
                .blur(radius: isLoading ? 2 : 0)
                .disabled(isLoading)
            
            DMLoadingView(loadingManager: loadingManager,
                          provider: provider)
        }

 #if DEBUG
        .onReceive(inspection?.notice ?? EmptyPublisher().notice) { [weak inspection] in
            inspection?.visit(self, $0)
        }
 #endif
    }
}
