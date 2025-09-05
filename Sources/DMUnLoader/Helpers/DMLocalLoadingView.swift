//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A custom SwiftUI view that provides local loading state management using a `DMLoadingManager`.
/// This view integrates with a `DMLoadingViewProviderProtocol` to manage and display loading states locally.
public struct DMLocalLoadingView<Content: View, Provider: DMLoadingViewProviderProtocol>: View {
    
    /// The provider responsible for supplying views and settings for loading, error, and success states.
    private let provider: Provider
    
    /// A closure that defines the content of the view.
    private let content: () -> Content
    
#if DEBUG
    /// An optional inspection instance used for testing purposes.
    /// - Note: This property is only available in debug builds.
    internal let inspection: Inspection<Self>? = getInspectionIfAvailable()
#endif
    
    /// The local loading manager responsible for managing the loading state.
    @StateObject internal var loadingManager: DMLoadingManager
    
    /// The global loading manager retrieved from the environment.
    @Environment(\.globalLoadingManager) internal var globalLoadingManager
    
    /// A computed property used to obtain the `DMLoadingManager` instance.
    /// - Note: This is primarily used for UIKit-based approaches to access the loading manager.
    private(set) internal var getLoadingManager: () -> DMLoadingManager
    
    /// Initializes a new instance of `DMLocalLoadingView`.
    /// - Parameters:
    ///   - provider: The provider responsible for supplying views and settings for loading, error, and success states.
    ///   - content: A closure that defines the content of the view.
    /// - Example:
    ///   ```swift
    ///   let provider = DefaultDMLoadingViewProvider()
    ///   let localLoadingView = DMLocalLoadingView(provider: provider) {
    ///       Text("Hello, World!")
    ///   }
    ///   ```
    public init(provider: Provider,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.provider = provider
        
        // Initialize a new `DMLoadingManager` instance.
        let newLoadingManager = DMLoadingManager(state: .none,
                                                 settings: provider.loadingManagerSettings)
        self.getLoadingManager = {
            newLoadingManager
        }
        
        _loadingManager = StateObject(wrappedValue: newLoadingManager)
    }
    
    /// The body of the `DMLocalLoadingView`.
    /// - Returns: A view that applies local loading state management using the `DMLoadingManager`.
    /// - Behavior:
    ///   - Wraps the provided content with the `autoLoading` modifier to enable local loading state management.
    ///   - Subscribes to the global loading manager when the view appears.
    ///   - Unsubscribes from the global loading manager when the view disappears.
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
