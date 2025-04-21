//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

/// A namespace for constants used in the `DMRootLoadingModifier`.
/// These constants define unique tags for views within the root loading modifier.
internal enum DMRootLoadingModifierOwnSettings {
    
    /// The tag assigned to the container view that holds all content.
    static let containerViewTag: Int = 4301
    
    /// The tag assigned to the blocking view that intercepts user interactions during loading.
    static let blockingViewTag: Int = 4302
    
    /// The tag assigned to the semi-transparent color view used for blocking interactions.
    static let blockingColorViewTag: Int = 4304
    
    /// The tag assigned to the main content view inside the container.
    static let containerContentViewTag: Int = 4305
}

/// A `ViewModifier` that applies a global loading state to the root view of an application.
/// This modifier observes the global loading state and displays a blocking overlay when necessary.
internal struct DMRootLoadingModifier<GLM: GlobalLoadingStateManagerInternalProtocol>: ViewModifier {
    
    /// The global loading state manager responsible for managing the loading state.
    @ObservedObject var globalLoadingStateManager: GLM
    
    /// Applies the root loading modifier to the content view.
    /// - Parameter content: The original view to which the modifier is applied.
    /// - Returns: A modified view with a blocking overlay displayed when the global loading state is active.
    /// - Behavior:
    ///   - When `globalLoadingStateManager.isLoading` is `true`, a `BlockingView` is displayed on top of the content.
    ///   - The `BlockingView` intercepts user interactions to prevent interaction with the underlying content.
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

/// A private view used as a blocking overlay to intercept user interactions during loading.
private struct BlockingView: View {
    
    /// The body of the `BlockingView`.
    /// - Returns: A semi-transparent gray color view that covers the entire screen.
    var body: some View {
        Color
            .gray
            .opacity(0.001) // Nearly transparent to allow visual focus on the underlying content
            .ignoresSafeArea() // Ensures the view covers the entire screen, including safe areas
            .tag(DMRootLoadingModifierOwnSettings.blockingColorViewTag)
    }
}
