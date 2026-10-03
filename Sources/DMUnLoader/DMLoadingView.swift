//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A custom SwiftUI view that displays a loading state based on the `loadableState` of a `loadingManager`.
/// This view uses a `provider` to supply views for different states (loading, failure, success).
struct DMLoadingView<LLM: DMLoadingManager>: View {
    @ObservedObject private(set) var loadingManager: LLM
    private let viewModel: any HUDViewModel
    @State private var animateTheAppearance = false

    /// - Parameter viewModel: Decides what the view shows of the state of `loadingManager`
    ///   and what a tap and Close do. The view observes `loadingManager` to draw its changes.
    init(loadingManager: LLM, viewModel: any HUDViewModel) {
        self.loadingManager = loadingManager
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    private var overlayView: some View {
        let loadableState = loadingManager.loadableState
        switch loadableState {
        case .none:
            EmptyView()
        case let .loading(provider):
            provider.getLoadingView()
        case let .failure(error, provider, onRetry):
            provider.getErrorView(
                error: error,
                onRetry: onRetry,
                onClose: DMButtonAction(viewModel.closeTapped)
            )
        case let .success(object, provider):
            provider.getSuccessView(object: object)
        }
    }
    
    var body: some View {
        ZStack {
            if !viewModel.showsHUD {
                overlayView
            } else {
                ZStack {
                    Color.black.opacity(animateTheAppearance ? 0.2 : 0)
                        .ignoresSafeArea()
                    
                    overlayView
                        .padding(15)
                        .background(Color.gray.opacity(animateTheAppearance ? 0.8 : 0.1))
                        .cornerRadius(10)
                        .scaleEffect(animateTheAppearance ? 1 : 0.9)
                        .padding(15)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: loadingManager.loadableState)
            }
        }
        .onAppear {
            animateTheAppearance = true
        }
        .animation(Animation.spring(duration: 0.2),
                   value: animateTheAppearance)
        .onTapGesture {
            viewModel.tapped()
        }
    }
}
