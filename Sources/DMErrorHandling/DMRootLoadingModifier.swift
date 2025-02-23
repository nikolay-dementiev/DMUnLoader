//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

internal enum DMRootLoadingModifierOwnSettings {
    static let containerViewTag: Int = 4301
    static let blockingViewTag: Int = 4302
    static let blockingColorViewTag: Int = 4304
    static let containerContentViewTag: Int = 4305
    
}

internal struct DMRootLoadingModifier<GLM: GlobalLoadingStateManagerInternalProtocol>: ViewModifier {
    @ObservedObject var globalLoadingStateManager: GLM
    
    public func body(content: Content) -> some View {
        return ZStack {
            content
                .tag(DMRootLoadingModifierOwnSettings.containerContentViewTag)
            
            if globalLoadingStateManager.isLoading {
                BlockingView()
                    // Catch any user interaction within this view
                    .allowsHitTesting(true)
                    .tag(DMRootLoadingModifierOwnSettings.blockingViewTag)
            }
        }
        .tag(DMRootLoadingModifierOwnSettings.containerViewTag)
    }
}

private struct BlockingView: View {
    var body: some View {
        Color
            .gray
            .opacity(0.001)
            .ignoresSafeArea()
            .tag(DMRootLoadingModifierOwnSettings.blockingColorViewTag)
    }
}
