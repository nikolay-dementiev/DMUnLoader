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
    @Environment(\.hudReducesMotion) private var reducesMotion
    private let dim: HUDBackdropDrawing.Dim

    /// - Parameters:
    ///   - viewModel: Decides what the view shows of the state of `loadingManager` and what a
    ///     tap and Close do. The view observes `loadingManager` to draw its changes.
    ///   - dim: The dim of the backdrop, faded in with the card.
    init(loadingManager: LLM, viewModel: any HUDViewModel, dim: HUDBackdropDrawing.Dim = .standard) {
        self.loadingManager = loadingManager
        self.viewModel = viewModel
        self.dim = dim
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
    
    /// The dim of the backdrop, faded in with the card.
    @ViewBuilder
    private var dimView: some View {
        switch dim {
        case .standard:
            defaultDim
        case let .color(color):
            color
                .ignoresSafeArea()
                .opacity(animateTheAppearance ? 1 : 0)
        case .none:
            EmptyView()
        }
    }

    /// The black dim of the default backdrop.
    private var defaultDim: some View {
        Color.black.opacity(animateTheAppearance ? 0.2 : 0)
            .ignoresSafeArea()
    }

    var body: some View {
        ZStack {
            if !viewModel.showsHUD {
                overlayView
            } else {
                ZStack {
                    dimView
                    
                    // Takes every tap outside the card, whatever the backdrop draws.
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            _ = viewModel.backdropTapped()
                        }
                    
                    HUDCard(isShown: animateTheAppearance, content: AnyView(overlayView))
                        .onTapGesture {
                            viewModel.cardTapped()
                        }
                        // Under Reduce Motion the card only fades in.
                        .scaleEffect(animateTheAppearance || reducesMotion ? 1 : 0.9)
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
    }
}

/// The card of a shown HUD: the view of the state on a rounded background. A tap anywhere on
/// the card is a tap on the card, between the lines of its text too.
struct HUDCard: View {
    @Environment(\.hudReducesTransparency) private var reducesTransparency
    let isShown: Bool
    let content: AnyView
    
    var body: some View {
        content
            .padding(15)
            .background(Color.gray.opacity(backgroundOpacity))
            .cornerRadius(10)
            .contentShape(RoundedRectangle(cornerRadius: 10))
    }

    /// Opaque under Reduce Transparency, so nothing behind the card shows through it.
    private var backgroundOpacity: Double {
        reducesTransparency ? 1 : (isShown ? 0.8 : 0.1)
    }
}

// MARK: - Previews

@MainActor
private func loadingViewPreview(_ state: (AnyDMLoadingViewProvider) -> DMLoadableType) -> some View {
    let state = state(DefaultDMLoadingViewProvider().eraseToAnyViewProvider())
    let manager = DMLoadingManagerMain(state: state, settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600)))
    return DMLoadingView(loadingManager: manager, viewModel: DefaultHUDViewModel(loadingManager: manager))
}

#Preview("Loading") {
    loadingViewPreview { .loading(provider: $0) }
}

#Preview("Loading under Reduce Motion") {
    loadingViewPreview { .loading(provider: $0) }
        .environment(\.hudReducesMotion, true)
}

#Preview("Success") {
    loadingViewPreview { .success("Saved", provider: $0) }
}

#Preview("Failure without Retry") {
    loadingViewPreview { .failure(error: DMAppError.custom("Failed"), provider: $0) }
}

#Preview("Failure with Retry") {
    loadingViewPreview { .failure(error: DMAppError.custom("Failed"), provider: $0, onRetry: DMButtonAction {}) }
}
