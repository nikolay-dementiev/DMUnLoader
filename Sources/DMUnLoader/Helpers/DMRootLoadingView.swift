//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUICore

/// A custom SwiftUI view that provides a root-level loading state management system.
/// This view integrates with a `GlobalLoadingStateManager` to manage and display loading states globally.
public struct DMRootLoadingView<Content: View>: View {
    
    /// A unique identifier for the `DMRootLoadingView`.
    internal let id: UUID = UUID()
    
    /// A closure that defines the content of the view, receiving the `GlobalLoadingStateManager` as a parameter.
    private let content: (GlobalLoadingStateManager) -> Content
    
    /// A computed property used to obtain the `GlobalLoadingStateManager` instance.
    /// - Note: This is primarily used for UIKit-based approaches to access the loading manager.
    private(set) internal var getLoadingManager: () -> GlobalLoadingStateManager
    
    /// The global loading state manager responsible for managing the root-level loading state.
    @StateObject private var globalLoadingStateManager: GlobalLoadingStateManager
    
    /// Initializes a new instance of `DMRootLoadingView`.
    /// - Parameter content: A closure that defines the content of the view,
    /// receiving the `GlobalLoadingStateManager` as a parameter.
    /// - Example:
    ///   ```swift
    ///   let rootView = DMRootLoadingView { loadingManager in
    ///       Text("Hello, World!")
    ///           .environmentObject(loadingManager)
    ///   }
    ///   ```
    public init(@ViewBuilder content: @escaping (GlobalLoadingStateManager) -> Content) {
        self.content = content
        
        // Initialize a new `GlobalLoadingStateManager` instance.
        let newLoadingManager = GlobalLoadingStateManager()
        self.getLoadingManager = {
            newLoadingManager
        }
        _globalLoadingStateManager = StateObject(wrappedValue: newLoadingManager)
    }
    
    /// The body of the `DMRootLoadingView`.
    /// - Returns: A view that applies root-level loading state management using the `GlobalLoadingStateManager`.
    /// - Behavior:
    ///   - Wraps the provided content with the `rootLoading` modifier to enable global loading state management.
    ///   - Ensures the view ignores safe areas to cover the entire screen.
    public var body: some View {
        let loadingManager = getLoadingManager()
        return content(loadingManager)
            .rootLoading(globalManager: loadingManager)
            .ignoresSafeArea()
    }
}
