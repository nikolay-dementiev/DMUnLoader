//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

public struct DMRootLoadingView<Content: View>: View {
    internal let id: UUID = UUID()
    private let content: (GlobalLoadingStateManager) -> Content
    
    // uses for UIKit's approach to obtain Loading Manager object
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
        let loadingManager = getLoadingManager()
        return content(loadingManager)
            .rootLoading(globalManager: loadingManager)
            .ignoresSafeArea()
    }
}
