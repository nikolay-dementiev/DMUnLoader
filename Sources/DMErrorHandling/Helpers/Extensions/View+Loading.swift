//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 22.01.2025.
//

import SwiftUI

public extension View {
    internal func autoLoading<Provider: DMLoadingViewProviderProtocol,
                              LLM: DMLoadingManagerInteralProtocol>
    (_ loadingManager: LLM,
     provider: Provider,
     modifier: DMLoadingModifier<Provider, LLM>? = nil) -> some View {
        self
            .environmentObject(loadingManager)
            .environmentObject(provider)
            .modifier(modifier ?? DMLoadingModifier(loadingManager: loadingManager, provider: provider))
    }
    
    internal func subscribeToGloabalLoadingManagers<GLM: GlobalLoadingStateManagerInternalProtocol,
                                                    LLM: DMLoadingManagerInteralProtocol>
    (localManager localLoadingManager: LLM,
     globalManager globalLoadingManager: GLM?) {
        
        guard let globalLoadingManager else {
            print("\(#function): @Environment(\\.gloabalLoadingManager) doesn't contains required value")
            return
        }
        
        globalLoadingManager.subscribeToLoadingManagers(localLoadingManager)
    }
    
    internal func unsubscribeFromLoadingManager<GLM: GlobalLoadingStateManagerInternalProtocol,
                                                LLM: DMLoadingManagerInteralProtocol>
    (localManager localLoadingManager: LLM,
     globalManager globalLoadingManager: GLM?) {
        
        guard let globalLoadingManager else {
            print("\(#function): @Environment(\\.gloabalLoadingManager) doesn't contains required value")
            return
        }
        
        globalLoadingManager.unsubscribeFromLoadingManager(localLoadingManager)
    }
    
    internal func rootLoading<GLM: GlobalLoadingStateManagerInternalProtocol>
    (globalManager globalLoadingManager: GLM) -> some View where GLM: GlobalLoadingStateManager {
        self
            .environment(\.globalLoadingManager, globalLoadingManager)
            .modifier(DMRootLoadingModifier(globalLoadingStateManager: globalLoadingManager))
    }
}
