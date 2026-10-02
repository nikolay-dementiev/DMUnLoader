import UIKit
import XCTest

/// The HUD window of the running example app. The app starts on its SwiftUI path, where
/// `DMRootLoadingView` hands a loading manager to the scene delegate.
@MainActor
final class HUDWindowTests: XCTestCase {

    func test_launchedApp_showsOneVisibleHUDWindow() throws {
        let scene = try XCTUnwrap(windowScene(), "the example app has a connected window scene")

        let windows = waitForHUDWindows(in: scene)

        XCTAssertEqual(windows.count, 1, "one HUD window in the scene")
        XCTAssertEqual(windows.first?.isHidden, false, "the HUD window is shown, not only created")
    }

    // MARK: - Helpers

    private func windowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    /// The HUD window is the window of the library's own window class in the scene.
    private func hudWindows(in scene: UIWindowScene) -> [UIWindow] {
        scene.windows.filter { NSStringFromClass(type(of: $0)).hasSuffix("DMPassThroughWindow") }
    }

    /// The scene delegate gets its manager when the root view appears, which can be after
    /// the test starts, so the run loop turns until the window exists or time runs out.
    private func waitForHUDWindows(in scene: UIWindowScene, timeout: TimeInterval = 10) -> [UIWindow] {
        let deadline = Date().addingTimeInterval(timeout)
        while hudWindows(in: scene).isEmpty, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return hudWindows(in: scene)
    }
}
