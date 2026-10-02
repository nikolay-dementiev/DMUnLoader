import Combine
import Foundation
import DMUnLoader

/// What the demo screen does. Its SwiftUI and its UIKit version share this model.
@MainActor
final class DemoModel<LM: DMLoadingManager>: ObservableObject {
    /// How many taps reached the control that lies under the HUD.
    @Published private(set) var contentTaps = 0
    /// How many times the Retry button of the failure HUD ran its action.
    @Published private(set) var retries = 0

    private let loadingManager: LM
    private let provider = DefaultDMLoadingViewProvider()
    private let loadingDuration: Duration
    private var simulatedWork: Task<Void, Never>?

    init(loadingManager: LM, loadingDuration: Duration = LaunchOptions.current.loadingDuration) {
        self.loadingManager = loadingManager
        self.loadingDuration = loadingDuration
    }

    func contentTapped() {
        contentTaps += 1
    }

    /// Shows the loading HUD, then a success when the simulated work ends.
    func showLoading() {
        simulatedWork?.cancel()
        loadingManager.showLoading(provider: provider)
        simulatedWork = Task { [weak self, loadingDuration] in
            do {
                try await Task.sleep(for: loadingDuration)
            } catch {
                // Cancelled: a newer state replaced the loading HUD and must stay as it is.
                return
            }
            self?.showSuccess()
        }
    }

    func showSuccess() {
        simulatedWork?.cancel()
        loadingManager.showSuccess("Loaded", provider: provider)
    }

    /// Shows the failure HUD. Its Retry button counts the retry and starts the work again.
    func showFailure() {
        simulatedWork?.cancel()
        let retry = DMButtonAction { [weak self] in
            self?.retries += 1
            self?.showLoading()
        }
        loadingManager.showFailure(DemoError.serverDidNotAnswer, provider: provider, onRetry: retry)
    }
}

enum DemoError: LocalizedError {
    case serverDidNotAnswer

    var errorDescription: String? {
        "The server did not answer."
    }
}
