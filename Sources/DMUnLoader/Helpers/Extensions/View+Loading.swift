//
//  DMUnLoader
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
}
