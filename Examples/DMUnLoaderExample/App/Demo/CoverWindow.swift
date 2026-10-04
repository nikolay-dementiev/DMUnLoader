import SwiftUI
import UIKit

/// A window the host shows over its screen after a HUD, such as a privacy cover: a full-screen
/// control at the normal level that counts the taps it receives.
@MainActor
enum CoverWindow {
    private static var window: UIWindow?

    /// Shows the cover, made key and visible like a host's own window, on the next turn of the
    /// main actor. The caller requests the failure HUD first, so the cover comes after it; no
    /// fixed delay is involved.
    static func show() {
        Task { @MainActor in
            present()
        }
    }

    private static func present() {
        guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            return
        }
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(rootView: CoverView())
        window.makeKeyAndVisible()
        self.window = window
    }
}

private struct CoverView: View {
    @State private var taps = 0

    var body: some View {
        Button {
            taps += 1
        } label: {
            Text(DemoText.coverTaps(taps))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.orange.opacity(0.3))
        .ignoresSafeArea()
        .accessibilityIdentifier(DemoIdentifier.cover)
    }
}
