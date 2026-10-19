import DMUnLoader
import DMUnLoaderExample
import UIKit
import XCTest

/// What the hosted tests of the HUD share: the scene of the running example app, the scene delegate
/// that takes the managers they give it, the HUD window, the app's own window, and the turning of
/// the run loop until a condition holds.
@MainActor
extension XCTestCase {
    /// Takes the root view out of its window, and the window out of its scene.
    func remove(_ window: UIWindow) {
        window.rootViewController = nil
        window.isHidden = true
        window.windowScene = nil
    }

    func windowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    func connectedSceneDelegate() throws -> (UIWindowScene, DMSceneDelegateBase<DMLoadingManagerMain>) {
        let scene = try XCTUnwrap(windowScene(), "the example app has a connected window scene")
        _ = waitUntil(ExampleSceneDelegate.current != nil)
        let sceneDelegate = try XCTUnwrap(
            ExampleSceneDelegate.current,
            "the SwiftUI path installs DMSceneDelegateBase and the root view registers it"
        )
        return (scene, sceneDelegate)
    }

    /// The HUD window is the window of the library's own window class in the scene.
    func hudWindows(in scene: UIWindowScene) -> [UIWindow] {
        scene.windows.filter { NSStringFromClass(type(of: $0)).hasSuffix("DMPassThroughWindow") }
    }

    /// The app's own window: the one at the normal level that is no HUD window.
    func findAppWindow(in scene: UIWindowScene) throws -> UIWindow {
        try XCTUnwrap(
            scene.windows.first { !hudWindows(in: scene).contains($0) && $0.windowLevel == .normal },
            "the app's own window"
        )
    }

    /// The scene delegate gets its manager when the root view appears, which can be after
    /// the test starts, so the run loop turns until the window exists or time runs out.
    func waitForHUDWindows(in scene: UIWindowScene) -> [UIWindow] {
        _ = waitUntil(!hudWindows(in: scene).isEmpty)
        return hudWindows(in: scene)
    }

    /// Turns the run loop until `condition` holds or ten seconds pass.
    func waitUntil(_ condition: @autoclosure () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(10)
        while !condition(), Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }
}
