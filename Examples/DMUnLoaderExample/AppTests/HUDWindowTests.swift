import DMUnLoader
import DMUnLoaderExample
import UIKit
import XCTest

/// The HUD window of the running example app. The app starts on its SwiftUI path, where
/// `DMRootLoadingView` hands a loading manager to the scene delegate. The tests reach the
/// scene delegate through the public API and give it managers of their own; each test
/// leaves a manager set, so the app keeps a HUD window for the next one.
@MainActor
final class HUDWindowTests: XCTestCase {

    func test_launchedApp_showsOneVisibleHUDWindow() throws {
        let scene = try XCTUnwrap(windowScene(), "the example app has a connected window scene")

        let windows = waitForHUDWindows(in: scene)

        XCTAssertEqual(windows.count, 1, "one HUD window in the scene")
        XCTAssertEqual(windows.first?.isHidden, false, "the HUD window is shown, not only created")
    }

    func test_replacingTheManager_keepsTheSameWindow() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        let windowBefore = try XCTUnwrap(waitForHUDWindows(in: scene).first, "a HUD window before the replacement")

        sceneDelegate.loadingManager = DMLoadingManagerMain()

        let windowsAfter = hudWindows(in: scene)
        XCTAssertEqual(windowsAfter.count, 1, "still one HUD window after the replacement")
        XCTAssertTrue(windowsAfter.first === windowBefore, "the new manager gets the window of the old one")
        XCTAssertEqual(windowsAfter.first?.isHidden, false, "the reused window stays shown")
    }

    func test_settingNil_removesTheWindow_andANewManagerBringsItBack() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        _ = waitForHUDWindows(in: scene)

        sceneDelegate.loadingManager = nil
        let windowsWithoutManager = waitUntil(hudWindows(in: scene).isEmpty, in: scene)

        sceneDelegate.loadingManager = DMLoadingManagerMain()
        XCTAssertTrue(windowsWithoutManager, "without a manager the scene has no HUD window")
        XCTAssertEqual(hudWindows(in: scene).count, 1, "a new manager brings one HUD window back")
    }

    func test_replacedManager_isReleased() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        var first: DMLoadingManagerMain? = DMLoadingManagerMain()
        weak let releasedFirst = first
        sceneDelegate.loadingManager = first
        first = nil

        sceneDelegate.loadingManager = DMLoadingManagerMain()

        XCTAssertTrue(waitUntil(releasedFirst == nil, in: scene), "the HUD keeps no replaced manager alive")
    }

    // MARK: - Helpers

    private func windowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    private func connectedSceneDelegate() throws -> (UIWindowScene, DMSceneDelegateBase<DMLoadingManagerMain>) {
        let scene = try XCTUnwrap(windowScene(), "the example app has a connected window scene")
        _ = waitUntil(ExampleSceneDelegate.current != nil, in: scene)
        let sceneDelegate = try XCTUnwrap(
            ExampleSceneDelegate.current,
            "the SwiftUI path installs DMSceneDelegateBase and the root view registers it"
        )
        return (scene, sceneDelegate)
    }

    /// The HUD window is the window of the library's own window class in the scene.
    private func hudWindows(in scene: UIWindowScene) -> [UIWindow] {
        scene.windows.filter { NSStringFromClass(type(of: $0)).hasSuffix("DMPassThroughWindow") }
    }

    /// The scene delegate gets its manager when the root view appears, which can be after
    /// the test starts, so the run loop turns until the window exists or time runs out.
    private func waitForHUDWindows(in scene: UIWindowScene) -> [UIWindow] {
        _ = waitUntil(!hudWindows(in: scene).isEmpty, in: scene)
        return hudWindows(in: scene)
    }

    /// Turns the run loop until `condition` holds or ten seconds pass.
    private func waitUntil(_ condition: @autoclosure () -> Bool, in scene: UIWindowScene) -> Bool {
        let deadline = Date().addingTimeInterval(10)
        while !condition(), Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }
}
