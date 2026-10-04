import os
import SwiftUI
import UIKit

/// A window the host shows over its screen after a HUD, such as a privacy cover: a full-screen
/// control at the normal level that counts the taps it receives.
@MainActor
enum CoverWindow {
    private static let logger = Logger(subsystem: "DMUnLoaderExample", category: "cover")
    private static var window: UIWindow?

    /// Shows the cover, made key and visible like a host's own window, once the HUD has hidden the
    /// windows under it from assistive technology. SwiftUI draws the state of the HUD after the
    /// request, and a cover shown before then is hidden with the windows under it. Polls every
    /// 10 milliseconds, and gives up after two seconds.
    static func show() {
        Task { @MainActor in
            do {
                var polls = 0
                while !hidesContentUnderneath(), polls < 200 {
                    polls += 1
                    try await Task.sleep(for: .milliseconds(10))
                }
                if !hidesContentUnderneath() {
                    logger.error("The HUD hid no window within two seconds, so the cover is shown anyway.")
                }
            } catch {
                // Nothing cancels this task today; a cancelled wait leaves nothing to cover.
                return
            }
            present()
        }
    }

    /// Whether a window of a connected scene is hidden from assistive technology. The HUD hides
    /// the windows under it while it shows.
    private static func hidesContentUnderneath() -> Bool {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .contains { $0.accessibilityElementsHidden }
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
