import SwiftUI
import DMUnLoader

final class CustomDMLoadingViewProvider: DMLoadingViewProvider {
    @MainActor
    func getLoadingView() -> some View {
        Text("Custom Loading View")
            .padding()
            .background(Color.blue)
    }

    @MainActor
    func getErrorView(
        error: Error,
        onRetry: DMAction?,
        onClose: DMAction
    ) -> some View {
        VStack {
            Text("Custom Error View")
            if let onRetry = onRetry {
                Button("Retry", action: onRetry.simpleAction)
            }
            Button("Close", action: onClose.simpleAction)
        }
    }

    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
        Text("Custom Success View")
    }
}

extension CustomDMLoadingViewProvider {
    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(
            successImageProperties: SuccessImageProperties(
                foregroundColor: .green
            )
        )
    }
}

/// The README of 1.0.x also set the auto-hide delay in the provider. The library never read it,
/// and a provider written that way must still compile.
extension CustomDMLoadingViewProvider {
    var loadingManagerSettings: DMLoadingManagerSettings {
        CustomLoadingManagerSettings()
    }

    private struct CustomLoadingManagerSettings: DMLoadingManagerSettings {
        var autoHideDelay: Duration = .seconds(4)
    }
}

@MainActor
func readmeSettingsUsage<LM: DMLoadingManager>(loadingManager: LM) {
    let provider = CustomDMLoadingViewProvider()
    loadingManager.showSuccess(
        "Data successfully loaded!",
        provider: provider
    )
}
