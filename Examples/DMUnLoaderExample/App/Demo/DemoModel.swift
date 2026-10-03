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
    private let provider = DemoProvider.make(hostTexts: LaunchOptions.current.usesHostTexts)
    private let loadingDuration: Duration
    private let retryCountsOnly: Bool
    private var simulatedWork: Task<Void, Never>?

    init(
        loadingManager: LM,
        loadingDuration: Duration = LaunchOptions.current.loadingDuration,
        retryCountsOnly: Bool = LaunchOptions.current.retryCountsOnly
    ) {
        self.loadingManager = loadingManager
        self.loadingDuration = loadingDuration
        self.retryCountsOnly = retryCountsOnly
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
            // A cancel can also arrive after the sleep ended and before this task resumed.
            guard !Task.isCancelled else { return }
            self?.showSuccess()
        }
    }

    func showSuccess() {
        simulatedWork?.cancel()
        loadingManager.showSuccess("Loaded", provider: provider)
    }

    /// Shows the failure HUD. Its Retry button counts the retry and starts the work again,
    /// or only counts it when the launch asks for that.
    func showFailure() {
        simulatedWork?.cancel()
        let retry = DMButtonAction { [weak self] in
            guard let self else { return }
            retries += 1
            if !retryCountsOnly {
                showLoading()
            }
        }
        loadingManager.showFailure(DemoError.serverDidNotAnswer, provider: provider, onRetry: retry)
        if LaunchOptions.current.coverAfterHUD {
            CoverWindow.show(after: .seconds(1))
        }
    }
}

enum DemoError: LocalizedError {
    case serverDidNotAnswer

    var errorDescription: String? {
        "The server did not answer."
    }
}

/// The view provider of the demo: the library's default texts, or the host's own texts.
enum DemoProvider {
    @MainActor
    static func make(hostTexts: Bool) -> DefaultDMLoadingViewProvider {
        guard hostTexts else {
            return DefaultDMLoadingViewProvider()
        }
        return DefaultDMLoadingViewProvider(
            loadingViewSettings: DMProgressViewDefaultSettings(
                loadingTextProperties: ProgressTextProperties(text: DemoText.Host.loading)
            ),
            errorViewSettings: DMErrorDefaultViewSettings(
                errorText: DemoText.Host.title,
                actionButtonCloseSettings: ActionButtonSettings(text: DemoText.Host.close),
                actionButtonRetrySettings: ActionButtonSettings(text: DemoText.Host.retry)
            )
        )
    }
}
