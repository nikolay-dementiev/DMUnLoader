import SwiftUI
import DMUnLoader

/// The screen under the HUD: three triggers and a control that counts the taps it gets.
struct DemoScreen<LM: DMLoadingManager>: View {
    @StateObject private var model: DemoModel<LM>

    init(loadingManager: LM) {
        _model = StateObject(wrappedValue: DemoModel(loadingManager: loadingManager))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(DemoText.contentTaps(model.contentTaps))
                .accessibilityIdentifier(DemoIdentifier.contentTaps)
            Text(DemoText.retries(model.retries))
                .accessibilityIdentifier(DemoIdentifier.retries)

            HStack(spacing: 12) {
                Button("Loading", action: model.showLoading)
                    .accessibilityIdentifier(DemoIdentifier.showLoading)
                Button("Success", action: model.showSuccess)
                    .accessibilityIdentifier(DemoIdentifier.showSuccess)
                Button("Failure", action: model.showFailure)
                    .accessibilityIdentifier(DemoIdentifier.showFailure)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button(action: model.contentTapped) {
                Text("Content under the HUD.\nA tap counts when it arrives here.")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            }
            .accessibilityIdentifier(DemoIdentifier.content)
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Idle") {
    DemoScreen(loadingManager: DMLoadingManagerMain())
}
