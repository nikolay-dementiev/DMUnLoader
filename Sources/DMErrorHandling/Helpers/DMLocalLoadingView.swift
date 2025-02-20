//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI

public struct DMLocalLoadingView<Content: View, Provider: DMLoadingViewProviderProtocol>: View {
    private let provider: Provider
    private let content: () -> Content
    
#if DEBUG
   internal let inspection: Inspection<Self>? = getInspectionIfAvailable()
#endif
    
    @StateObject internal var loadingManager: DMLoadingManager
    @Environment(\.globalLoadingManager) internal var globalLoadingManager
    
    // uses for UIKit's approach to obtain Loading Manager object
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
#if DEBUG
           .onReceive(inspection?.notice ?? EmptyPublisher().notice) { [weak inspection] in
               inspection?.visit(self, $0)
           }
#endif
    }
}
