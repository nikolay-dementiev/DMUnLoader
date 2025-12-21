//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A namespace for constants used in the `DMLoadingView`.
/// These constants define unique tags for views within the loading view.
enum DMLoadingViewOwnSettings {
    
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
struct DMLoadingView<LLM: DMLoadingManager>: View {
    @ObservedObject private(set) var loadingManager: LLM
    @State private var animateTheAppearance = false
    
#if DEBUG
    let inspection: Inspection<Self>? = getInspectionIfAvailable()
#endif
    
    init(loadingManager: LLM) {
        self.loadingManager = loadingManager
    }
    
    @ViewBuilder
    private var overlayView: some View {
        let loadableState = loadingManager.loadableState
        switch loadableState {
        case .none:
            EmptyView()
                .tag(DMLoadingViewOwnSettings.emptyViewTag)
        case let .loading(provider):
            provider.getLoadingView()
                .tag(DMLoadingViewOwnSettings.loadingViewTag)
        case let .failure(error, provider, onRetry):
            provider.getErrorView(
                error: error,
                onRetry: onRetry,
                onClose: DMButtonAction(loadingManager.hide)
            )
            .tag(DMLoadingViewOwnSettings.failureViewTag)
        case let .success(object, provider):
            provider.getSuccessView(object: object)
                .tag(DMLoadingViewOwnSettings.successViewTag)
        }
    }
    
    var body: some View {
        ZStack {
            let loadableState = loadingManager.loadableState
            switch loadableState {
            case .none:
                overlayView
            case .failure,
                    .loading,
                    .success:
                
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
                .tag(DMLoadingViewOwnSettings.defaultViewTag)
            }
        }
        .onAppear {
            animateTheAppearance.toggle()
        }
        .animation(Animation.spring(duration: 0.2),
                   value: animateTheAppearance)
        .onTapGesture {
            switch loadingManager.loadableState {
            case .success,
                    .failure,
                    .none:
                loadingManager.hide()
            case .loading:
                break
            }
        }
#if DEBUG
        .onReceive(inspection?.notice ?? EmptyPublisher().notice) { [weak inspection] in
            inspection?.visit(self, $0)
        }
#endif
        .tag(DMLoadingViewOwnSettings.tapGestureViewTag)
    }
}
