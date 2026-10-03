import DMUnLoader
import DMUnLoaderExample
import SwiftUI
import UIKit
import XCTest

/// The HUD window of the running example app. The app starts on its SwiftUI path, where
/// `DMRootLoadingView` hands a loading manager to the scene delegate. The tests reach the
/// scene delegate through the public API and give it managers of their own; each test
/// leaves a manager set, so the app keeps a HUD window for the next one. A root view with an
/// injected manager is shown in a window of its own, which its test removes.
@MainActor
final class HUDWindowTests: XCTestCase {

    func test_launchedApp_onTheSwiftUIPath_showsOneVisibleHUDWindow() throws {
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
        let windowsWithoutManager = waitUntil(hudWindows(in: scene).isEmpty)

        sceneDelegate.loadingManager = DMLoadingManagerMain()
        XCTAssertTrue(windowsWithoutManager, "without a manager the scene has no HUD window")
        XCTAssertEqual(hudWindows(in: scene).count, 1, "a new manager brings one HUD window back")
    }

    func test_replacedManager_afterANewManagerIsSet_isReleased() throws {
        let (_, sceneDelegate) = try connectedSceneDelegate()
        var first: DMLoadingManagerMain? = DMLoadingManagerMain()
        weak let releasedFirst = first
        sceneDelegate.loadingManager = first
        first = nil

        sceneDelegate.loadingManager = DMLoadingManagerMain()

        XCTAssertTrue(waitUntil(releasedFirst == nil), "the HUD keeps no replaced manager alive")
    }

    // MARK: - Window level

    func test_defaultSettings_hudWindow_isAtTheNormalLevel() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        sceneDelegate.loadingManager = DMLoadingManagerMain()

        let window = try XCTUnwrap(waitForHUDWindows(in: scene).first, "a HUD window")

        XCTAssertEqual(window.windowLevel, .normal, "the HUD window keeps the level of every release so far")
    }

    func test_settingsAboveNormal_hudWindow_isAtThatLevel() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        sceneDelegate.loadingManager = DMLoadingManagerMain(
            state: .none,
            settings: DMLoadingManagerDefaultSettings(hudWindowLevel: .normal + 1)
        )

        let window = try XCTUnwrap(waitForHUDWindows(in: scene).first, "a HUD window")

        XCTAssertEqual(window.windowLevel, .normal + 1, "the HUD window takes the level of the manager's settings")
    }

    func test_replacingTheManager_withAnotherLevel_movesTheReusedWindow() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        sceneDelegate.loadingManager = DMLoadingManagerMain()
        let window = try XCTUnwrap(waitForHUDWindows(in: scene).first, "a HUD window")

        sceneDelegate.loadingManager = DMLoadingManagerMain(
            state: .none,
            settings: DMLoadingManagerDefaultSettings(hudWindowLevel: .normal + 1)
        )

        XCTAssertTrue(hudWindows(in: scene).first === window, "the new manager reuses the window")
        XCTAssertEqual(window.windowLevel, .normal + 1, "the reused window moves to the level of the new manager")
    }

    /// A phone gives an app one scene, so this runs where the system supports more, such as
    /// an iPad. The test keeps the second scene's delegate alive, as a host may: the HUD window
    /// must still leave with its scene.
    func test_secondScene_showsItsOwnHUD_andClosingItRemovesOnlyThatOne() throws {
        let app = UIApplication.shared
        try XCTSkipUnless(app.supportsMultipleScenes, "a second scene needs a device that supports multiple scenes")
        let (firstScene, firstDelegate) = try connectedSceneDelegate()
        _ = waitForHUDWindows(in: firstScene)
        let secondScene = try openScene(besides: firstScene)
        _ = waitUntil(ExampleSceneDelegate.current !== firstDelegate)
        let secondDelegate = ExampleSceneDelegate.current
        weak var secondHUD: UIWindow?
        autoreleasepool {
            secondHUD = waitForHUDWindows(in: secondScene).first
        }
        let secondSceneShowedAHUD = secondHUD != nil

        app.requestSceneSessionDestruction(secondScene.session, options: nil)
        let closed = waitUntil(app.connectedScenes.count == 1)

        XCTAssertTrue(secondSceneShowedAHUD, "the second scene shows a HUD window of its own")
        XCTAssertTrue(closed, "the second scene disconnects")
        XCTAssertTrue(
            waitUntil(secondHUD == nil),
            "the closed scene's HUD window is released, although its scene delegate is alive"
        )
        XCTAssertEqual(hudWindows(in: firstScene).count, 1, "the first scene keeps its HUD window")
        XCTAssertNotNil(secondDelegate, "the second scene's delegate stays alive until the end of the test")
    }

    // MARK: - Root view with an injected manager

    func test_injectedRoot_inAWindowOfTheScene_addsOneVisibleHUDWindowToThatScene() throws {
        let scene = try XCTUnwrap(windowScene(), "the example app has a connected window scene")
        let before = waitForHUDWindows(in: scene)

        let window = showInjectedRoot(in: scene)
        defer { remove(window) }

        let added = waitUntil(hudWindows(in: scene).count == before.count + 1)
        let newWindow = hudWindows(in: scene).first { candidate in !before.contains { $0 === candidate } }
        XCTAssertTrue(added, "the root view adds one HUD window to the scene of its window")
        XCTAssertEqual(newWindow?.isHidden, false, "the new HUD window is shown, not only created")
    }

    func test_injectedRoot_removedFromItsWindow_removesItsHUDWindow() throws {
        let scene = try XCTUnwrap(windowScene(), "the example app has a connected window scene")
        let before = waitForHUDWindows(in: scene).count
        let window = showInjectedRoot(in: scene)
        let added = waitUntil(hudWindows(in: scene).count == before + 1)

        remove(window)

        XCTAssertTrue(added, "the root view adds its HUD window first")
        XCTAssertTrue(
            waitUntil(hudWindows(in: scene).count == before),
            "the HUD window leaves the scene with the root view"
        )
    }

    /// SwiftUI evaluates a root view in a window that belongs to no scene, but never puts it
    /// into that window (measured on iOS 17.5 and 26.5), so the view cannot learn a scene.
    func test_injectedRoot_inAWindowWithoutScene_addsNoHUDWindow() throws {
        let scene = try XCTUnwrap(windowScene(), "the example app has a connected window scene")
        let before = waitForHUDWindows(in: scene).count
        let appearance = Appearance()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIHostingController(
            rootView: DMRootLoadingView(manager: DMLoadingManagerMain()) { _ in
                Color.clear.onAppear { appearance.didAppear = true }
            }
        )
        window.isHidden = false
        defer { window.isHidden = true }

        let appeared = waitUntil(appearance.didAppear)
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))

        XCTAssertTrue(appeared, "SwiftUI evaluates the root view in a window without a scene")
        XCTAssertEqual(hudWindows(in: scene).count, before, "no HUD window joins a scene the view is not in")
    }

    /// A phone gives an app one scene, so this runs where the system supports more, such as
    /// an iPad: on a phone, a HUD that joined the first connected scene would pass as well.
    func test_injectedRoot_twoScenes_eachHUDJoinsTheSceneOfItsRootView() throws {
        try XCTSkipUnless(
            UIApplication.shared.supportsMultipleScenes,
            "a second scene needs a device that supports multiple scenes"
        )
        let (firstScene, _) = try connectedSceneDelegate()
        let secondScene = try openScene(besides: firstScene)
        defer { UIApplication.shared.requestSceneSessionDestruction(secondScene.session, options: nil) }
        let firstBefore = waitForHUDWindows(in: firstScene).count
        let secondBefore = waitForHUDWindows(in: secondScene).count

        let firstWindow = showInjectedRoot(in: firstScene)
        let secondWindow = showInjectedRoot(in: secondScene)
        defer {
            remove(firstWindow)
            remove(secondWindow)
        }

        XCTAssertTrue(
            waitUntil(hudWindows(in: firstScene).count == firstBefore + 1),
            "the HUD window of the first root view joins the first scene"
        )
        XCTAssertTrue(
            waitUntil(hudWindows(in: secondScene).count == secondBefore + 1),
            "the HUD window of the second root view joins the second scene"
        )
    }

    // MARK: - Helpers

    private final class Appearance {
        var didAppear = false
    }

    /// A window of `scene` whose root view is a `DMRootLoadingView` with a manager of its own.
    private func showInjectedRoot(in scene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(
            rootView: DMRootLoadingView(manager: DMLoadingManagerMain()) { _ in Color.clear }
        )
        window.isHidden = false
        return window
    }

    /// Takes the root view out of its window, and the window out of its scene.
    private func remove(_ window: UIWindow) {
        window.rootViewController = nil
        window.isHidden = true
        window.windowScene = nil
    }

    private func windowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    private func connectedSceneDelegate() throws -> (UIWindowScene, DMSceneDelegateBase<DMLoadingManagerMain>) {
        let scene = try XCTUnwrap(windowScene(), "the example app has a connected window scene")
        _ = waitUntil(ExampleSceneDelegate.current != nil)
        let sceneDelegate = try XCTUnwrap(
            ExampleSceneDelegate.current,
            "the SwiftUI path installs DMSceneDelegateBase and the root view registers it"
        )
        return (scene, sceneDelegate)
    }

    /// Opens another scene of the app. The system may decline, as the iPadOS 18.6 simulator
    /// does; the test is then skipped with the system's reason.
    private func openScene(besides scene: UIWindowScene) throws -> UIWindowScene {
        var declined: (any Error)?
        UIApplication.shared.activateSceneSession(for: UISceneSessionActivationRequest()) { declined = $0 }
        _ = waitUntil(UIApplication.shared.connectedScenes.count > 1 || declined != nil)
        if let declined {
            throw XCTSkip("the system declined to open a second scene: \(declined.localizedDescription)")
        }
        let otherScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0 !== scene }
        return try XCTUnwrap(otherScene, "the second scene connects")
    }

    /// The HUD window is the window of the library's own window class in the scene.
    private func hudWindows(in scene: UIWindowScene) -> [UIWindow] {
        scene.windows.filter { NSStringFromClass(type(of: $0)).hasSuffix("DMPassThroughWindow") }
    }

    /// The scene delegate gets its manager when the root view appears, which can be after
    /// the test starts, so the run loop turns until the window exists or time runs out.
    private func waitForHUDWindows(in scene: UIWindowScene) -> [UIWindow] {
        _ = waitUntil(!hudWindows(in: scene).isEmpty)
        return hudWindows(in: scene)
    }

    /// Turns the run loop until `condition` holds or ten seconds pass.
    private func waitUntil(_ condition: @autoclosure () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(10)
        while !condition(), Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }
}
