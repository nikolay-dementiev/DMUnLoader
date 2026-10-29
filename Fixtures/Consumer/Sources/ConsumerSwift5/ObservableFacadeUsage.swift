import Observation
import SwiftUI
import DMUnLoader

/// An app that keeps its loading manager as Observation state: the facade is the state, and the manager
/// that the facade wraps goes to the root view, which shows the HUD of that manager.
struct ObservableFacadeApp: App {
    @State private var loading = DMObservableLoadingManager(manager: DMLoadingManagerMain())

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView(manager: loading.manager) { _ in
                ObservableFacadeContent(loading: loading)
            }
        }
    }
}

/// A view that reads the state of the facade and calls its four operations, as it calls the manager's.
struct ObservableFacadeContent: View {
    let loading: DMObservableLoadingManager
    private let provider = DefaultDMLoadingViewProvider()

    var body: some View {
        VStack {
            Text(verbatim: loading.loadableState.rawValue)

            Button("Show loading") {
                loading.showLoading(provider: provider)
            }

            Button("Show success") {
                loading.showSuccess("Data successfully loaded!", provider: provider)
            }

            Button("Show failure") {
                loading.showFailure(NSError(domain: "Example", code: 404), provider: provider)
            }

            Button("Show failure with Retry") {
                loading.showFailure(
                    NSError(domain: "Example", code: 404),
                    provider: provider,
                    onRetry: DMButtonAction {}
                )
            }

            Button("Hide") {
                loading.hide()
            }
        }
    }
}

/// A host that follows the state by hand, as a UIKit host does where UIKit tracks nothing by itself.
@MainActor
func followLoadableState(of loading: DMObservableLoadingManager, onChange: @escaping @Sendable () -> Void) {
    withObservationTracking {
        _ = loading.loadableState
    } onChange: {
        onChange()
    }
}
