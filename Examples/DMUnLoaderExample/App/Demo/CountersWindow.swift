import DMUnLoader
import SwiftUI
import UIKit

/// The counters of the demo once more, in a strip at the bottom of the screen above the
/// HUD's level. It takes no touch. While a HUD is shown the library hides the app's other
/// windows from assistive technology, which the UI tests read the counters through; a window
/// above the HUD stays readable.
@MainActor
enum CountersWindow {
    private static var window: UIWindow?

    static func show<LM: DMLoadingManager>(for model: DemoModel<LM>) {
        guard window == nil,
              let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            return
        }
        let bounds = scene.coordinateSpace.bounds
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: bounds.height - 100, width: bounds.width, height: 100)
        window.windowLevel = .normal + 10
        window.isUserInteractionEnabled = false
        let controller = UIHostingController(rootView: CountersView(model: model))
        controller.view.backgroundColor = .clear
        window.rootViewController = controller
        window.isHidden = false
        self.window = window
    }
}

private struct CountersView<LM: DMLoadingManager>: View {
    @ObservedObject var model: DemoModel<LM>

    var body: some View {
        HStack {
            Text(DemoText.contentTaps(model.contentTaps))
                .accessibilityIdentifier(DemoIdentifier.windowContentTaps)
            Text(DemoText.retries(model.retries))
                .accessibilityIdentifier(DemoIdentifier.windowRetries)
        }
        .font(.caption)
    }
}
