//
//  DMRootLoadingView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUICore

public struct DMRootLoadingView<Content: View>: View {
    private let content: (GlobalLoadingStateManager) -> Content
    
    //uses for UIKit's approach to obtain Loading Manager object
    private(set) internal var getLoadingManager: () -> GlobalLoadingStateManager
    
    @StateObject private var globalLoadingStateManager: GlobalLoadingStateManager
    
    public init(@ViewBuilder content: @escaping (GlobalLoadingStateManager) -> Content) {
        self.content = content
        
        let newLoadingManager = GlobalLoadingStateManager()
        self.getLoadingManager = {
            newLoadingManager
        }
        _globalLoadingStateManager = StateObject(wrappedValue: newLoadingManager)
    }
    
    public var body: some View {
        return content(globalLoadingStateManager)
            .rootLoading(globalManager: globalLoadingStateManager)
            .ignoresSafeArea()
    }
}
