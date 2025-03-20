//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore
import Combine

/// A `ViewModifier` that adds a loading view to any SwiftUI `View`.
/// This modifier observes the state of a loading manager and displays a loading view when necessary.
internal struct DMLoadingModifier<Provider: DMLoadingViewProviderProtocol,
                                  LLM: DMLoadingManagerInteralProtocol>: ViewModifier {
    
    #if DEBUG
    /// An optional inspection instance used for testing purposes.
    /// - Note: This property is only available in debug builds.
    internal let inspection: Inspection<Self>? = getInspectionIfAvailable()
    #endif
    
    /// The loading manager responsible for managing the loadable state.
    @ObservedObject internal var loadingManager: LLM
    
    /// The provider that supplies views and settings for loading, error, and success states.
    internal var provider: Provider
    
    /// Applies the loading modifier to the content view.
    /// - Parameter content: The original view to which the modifier is applied.
    /// - Returns: A modified view with a loading overlay displayed when the loading state is active.
    /// - Behavior:
    ///   - When the `loadingManager.loadableState` is not `.none`, the content is blurred and disabled.
    ///   - A loading view (`DMLoadingView`) is displayed on top of the content.
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
