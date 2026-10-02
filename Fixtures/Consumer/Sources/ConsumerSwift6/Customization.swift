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
    var loadingManagerSettings: DMLoadingManagerSettings {
        CustomLoadingManagerSettings()
    }

    private struct CustomLoadingManagerSettings: DMLoadingManagerSettings {
        var autoHideDelay: Duration = .seconds(4)
    }

    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(
            successImageProperties: SuccessImageProperties(
                foregroundColor: .green
            )
        )
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
