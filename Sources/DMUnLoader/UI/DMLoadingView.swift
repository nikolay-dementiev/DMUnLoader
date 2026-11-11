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
    private let makeCloseCommand: @MainActor () -> DMButtonAction
    @State private var animateTheAppearance = false
    @Environment(\.hudReducesMotion) private var reducesMotion
    private let dim: HUDBackdropDrawing.Dim

    /// - Parameters:
    ///   - viewModel: Decides what the view shows of the state of `loadingManager` and what a
    ///     tap does. The view observes `loadingManager` to draw its changes.
    ///   - makeCloseCommand: Makes the command that the view hands the provider as `onClose` of the
    ///     error view of a failure. The view calls it once each time it builds that error view, and in
    ///     no other state. SwiftUI decides how often the view is built, so the factory must have no
    ///     side effects. A provider can tell the commands it is handed apart by their `id`, and each
    ///     build has always been handed a new one, so the factory should return a new command on each
    ///     call. The view holds the factory for as long as it lives, and what the factory captures too.
    ///   - dim: The dim of the backdrop, faded in with the card.
    init(
        loadingManager: LLM,
        viewModel: any HUDViewModel,
        makeCloseCommand: @escaping @MainActor () -> DMButtonAction,
        dim: HUDBackdropDrawing.Dim = .standard
    ) {
        self.loadingManager = loadingManager
        self.viewModel = viewModel
        self.makeCloseCommand = makeCloseCommand
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
                onClose: makeCloseCommand()
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
                    
                    HUDCard(
                        appearance: loadingManager.loadableState.hudAppearance,
                        isShown: animateTheAppearance,
                        content: AnyView(overlayView)
                    )
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
        .environment(\.hudAppearance, loadingManager.loadableState.hudAppearance)
    }
}

/// The card of a shown HUD: the view of the state on a rounded background. A tap anywhere on
/// the card is a tap on the card, between the lines of its text too.
package struct HUDCard: View {
    @Environment(\.hudReducesTransparency) private var reducesTransparency
    package let appearance: DMHUDAppearance
    let isShown: Bool
    let content: AnyView

    package init(appearance: DMHUDAppearance, isShown: Bool, content: AnyView) {
        self.appearance = appearance
        self.isShown = isShown
        self.content = content
    }

    package var body: some View {
        paddedContent
            .background(appearance.cardBackground(isShown: isShown, reducesTransparency: reducesTransparency))
            .cornerRadius(10)
            .contentShape(RoundedRectangle(cornerRadius: 10))
    }

    /// The content with the padding of the card. In the accessible look a card taller than the screen
    /// scrolls, so that no line of it is cut off at the largest text sizes.
    @ViewBuilder
    private var paddedContent: some View {
        switch appearance.kind {
        case .standard:
            content.padding(15)
        case .accessible:
            ViewThatFits(in: .vertical) {
                content.padding(15)
                ScrollView {
                    content.padding(15)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
    }
}

// MARK: - Previews

@MainActor
private func loadingViewPreview(
    appearance: DMHUDAppearance = .standard,
    _ state: (AnyDMLoadingViewProvider) -> DMLoadableType
) -> some View {
    let state = state(DefaultDMLoadingViewProvider(appearance: appearance).eraseToAnyViewProvider())
    let manager = DMLoadingManagerMain(state: state, settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600)))
    let viewModel = DefaultHUDViewModel(model: LoadingManagerHUDModel(manager))
    return DMLoadingView(
        loadingManager: manager,
        viewModel: viewModel,
        makeCloseCommand: { DMButtonAction(viewModel.closeTapped) }
    )
}

#Preview("Loading") {
    loadingViewPreview { .loading(provider: $0) }
}

#Preview("Loading under Reduce Motion") {
    loadingViewPreview { .loading(provider: $0) }
        .environment(\.hudReducesMotion, true)
}

#Preview("Loading under Reduce Transparency") {
    loadingViewPreview { .loading(provider: $0) }
        .environment(\.hudReducesTransparency, true)
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

#Preview("Loading, accessible look") {
    loadingViewPreview(appearance: .accessible) { .loading(provider: $0) }
}

#Preview("Loading, accessible look, accessibility 5") {
    loadingViewPreview(appearance: .accessible) { .loading(provider: $0) }
        .dynamicTypeSize(.accessibility5)
}

#Preview("Success, accessible look") {
    loadingViewPreview(appearance: .accessible) { .success("Saved", provider: $0) }
}

#Preview("Failure with Retry, accessible look") {
    loadingViewPreview(appearance: .accessible) {
        .failure(error: DMAppError.custom("Failed"), provider: $0, onRetry: DMButtonAction {})
    }
}

#Preview("Failure with Retry, accessible look, accessibility 3") {
    loadingViewPreview(appearance: .accessible) {
        .failure(error: DMAppError.custom("Failed"), provider: $0, onRetry: DMButtonAction {})
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("Failure with Retry, accessible look, dark") {
    loadingViewPreview(appearance: .accessible) {
        .failure(error: DMAppError.custom("Failed"), provider: $0, onRetry: DMButtonAction {})
    }
    .preferredColorScheme(.dark)
}
