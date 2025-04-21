//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// An extension on `View` to provide utility methods for managing loading states in SwiftUI views.
public extension View {
    
    /// Applies automatic loading state management to the view using a loading manager and a provider.
    /// - Parameters:
    ///   - loadingManager: The local loading manager responsible for managing the loading state.
    ///   - provider: The provider that supplies the view for the loading state.
    ///   - modifier: An optional custom modifier to apply additional behavior. If not provided,
    ///               a default `DMLoadingModifier` is used.
    /// - Returns: A modified view with the loading state management applied.
    /// - Example:
    ///   ```swift
    ///   struct ContentView: View {
    ///       @StateObject private var loadingManager = DMLoadingManager(state: .none,
    ///       settings: DMLoadingManagerDefaultSettings())
    ///       let provider = DefaultDMLoadingViewProvider()
    ///
    ///       var body: some View {
    ///           Text("Hello, World!")
    ///               .autoLoading(loadingManager, provider: provider)
    ///       }
    ///   }
    ///   ```
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
    
    /// Subscribes a local loading manager to a global loading state manager.
    /// - Parameters:
    ///   - localLoadingManager: The local loading manager to subscribe.
    ///   - globalLoadingManager: The global loading state manager to which the local manager will be subscribed.
    ///                           If `nil`, a warning message is printed.
    /// - Note: This method ensures that the local manager's state is synchronized with the global manager.
    /// - Example:
    ///   ```swift
    ///   struct ContentView: View {
    ///       @Environment(\.globalLoadingManager) private var globalLoadingManager
    ///       @StateObject private var localLoadingManager =
    ///       DMLoadingManager(state: .none, settings: DMLoadingManagerDefaultSettings())
    ///
    ///       var body: some View {
    ///           Text("Hello, World!")
    ///               .onAppear {
    ///                   subscribeToGloabalLoadingManagers(localManager: localLoadingManager,
    ///                                                     globalManager: globalLoadingManager)
    ///               }
    ///       }
    ///   }
    ///   ```
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
    
    /// Unsubscribes a local loading manager from a global loading state manager.
    /// - Parameters:
    ///   - localLoadingManager: The local loading manager to unsubscribe.
    ///   - globalLoadingManager: The global loading state manager from which the local manager will be unsubscribed.
    ///                           If `nil`, a warning message is printed.
    /// - Note: This method ensures that the local manager's state is no longer synchronized with the global manager.
    /// - Example:
    ///   ```swift
    ///   struct ContentView: View {
    ///       @Environment(\.globalLoadingManager) private var globalLoadingManager
    ///       @StateObject private var localLoadingManager =
    ///       DMLoadingManager(state: .none, settings: DMLoadingManagerDefaultSettings())
    ///
    ///       var body: some View {
    ///           Text("Hello, World!")
    ///               .onDisappear {
    ///                   unsubscribeFromLoadingManager(localManager: localLoadingManager, globalManager: globalLoadingManager)
    ///               }
    ///       }
    ///   }
    ///   ```
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
    
    /// Applies root-level loading state management to the view using a global loading state manager.
    /// - Parameter globalLoadingManager: The global loading state manager responsible for managing the root-level loading state.
    /// - Returns: A modified view with the root-level loading state management applied.
    /// - Example:
    ///   ```swift
    ///   struct ContentView: View {
    ///       @StateObject private var globalLoadingManager = GlobalLoadingStateManager()
    ///
    ///       var body: some View {
    ///           Text("Hello, World!")
    ///               .rootLoading(globalManager: globalLoadingManager)
    ///       }
    ///   }
    ///   ```
    internal func rootLoading<GLM: GlobalLoadingStateManagerInternalProtocol>
    (globalManager globalLoadingManager: GLM) -> some View where GLM: GlobalLoadingStateManager {
        self
            .environment(\.globalLoadingManager, globalLoadingManager)
            .modifier(DMRootLoadingModifier(globalLoadingStateManager: globalLoadingManager))
    }
}
