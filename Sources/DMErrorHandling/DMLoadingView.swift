//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A namespace for constants used in the `DMLoadingView`.
/// These constants define unique tags for views within the loading view.
internal enum DMLoadingViewOwnSettings {
    
    /// The tag assigned to an empty view when no loading state is active.
    static let emptyViewTag: Int = 0001
    
    /// The tag assigned to the default container view that holds all loading states.
    static let defaultViewTag: Int = 0102
    
    /// The tag assigned to the loading view displayed during the `.loading` state.
    static let loadingViewTag: Int = 0203
    
    /// The tag assigned to the failure view displayed during the `.failure` state.
    static let failureViewTag: Int = 0304
    
    /// The tag assigned to the success view displayed during the `.success` state.
    static let successViewTag: Int = 0405
    
    /// The tag assigned to the tap gesture view used to dismiss certain states.
    static let tapGestureViewTag: Int = 0515
}

/// A custom SwiftUI view that displays a loading state based on the `loadableState` of a `loadingManager`.
/// This view uses a `provider` to supply views for different states (loading, failure, success).
internal struct DMLoadingView<Provider: DMLoadingViewProviderProtocol,
                              LLM: DMLoadingManagerInteralProtocol>: View {
    
    /// The loading manager responsible for managing the loadable state.
    @ObservedObject private(set) internal var loadingManager: LLM
    
    /// The provider that supplies views and settings for loading, error, and success states.
    internal var provider: Provider
    
    /// Initializes a new instance of `DMLoadingView`.
    /// - Parameters:
    ///   - loadingManager: The loading manager responsible for managing the loadable state.
    ///   - provider: The provider that supplies views and settings for different states.
    internal init(loadingManager: LLM,
                  provider: Provider) {
        self.loadingManager = loadingManager
        self.provider = provider
    }
    
    /// The body of the `DMLoadingView`.
    /// - Returns: A view that dynamically updates based on the `loadableState` of the `loadingManager`.
    /// - Behavior:
    ///   - Displays an empty view when the state is `.none`.
    ///   - Displays a semi-transparent overlay with a loading, failure, or success view based on the current state.
    ///   - Includes a tap gesture to dismiss the view when appropriate.
    internal var body: some View {
        ZStack {
            let loadableState = loadingManager.loadableState
            switch loadableState {
            case .none:
                EmptyView()
                    .tag(DMLoadingViewOwnSettings.emptyViewTag)
            case .failure, .loading, .success:
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        if case .loading = loadableState {
                            provider.getLoadingView()
                                .tag(DMLoadingViewOwnSettings.loadingViewTag)
                        } else if case .failure(let error, let onRetry) = loadableState {
                            provider.getErrorView(error: error,
                                                  onRetry: onRetry,
                                                  onClose: DMButtonAction(loadingManager.hide))
                            .tag(DMLoadingViewOwnSettings.failureViewTag)
                        } else if case .success(let object) = loadableState {
                            provider.getSuccessView(object: object)
                                .tag(DMLoadingViewOwnSettings.successViewTag)
                        }
                    }
                    .padding(30)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: loadingManager.loadableState)
                .tag(DMLoadingViewOwnSettings.defaultViewTag)
            }
        }.onTapGesture {
            switch loadingManager.loadableState {
            case .success,
                    .failure,
                    .none:
                loadingManager.hide()
            case .loading:
                break
            }
        }
        .tag(DMLoadingViewOwnSettings.tapGestureViewTag)
    }
}
