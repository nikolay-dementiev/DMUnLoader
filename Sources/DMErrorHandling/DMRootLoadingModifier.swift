//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

internal struct DMRootLoadingModifier<GLM: GlobalLoadingStateManagerInternalProtocol>: ViewModifier {
    @ObservedObject var globalLoadingStateManager: GLM
    
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
