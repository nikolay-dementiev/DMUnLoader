import DMUnLoader
import DMUnLoaderExample
import UIKit
import XCTest

/// What the HUD hides from assistive technology while it stays on the screen and its manager is
/// replaced by one at another window level. Each test here pins defect C-8.1 as it is today: it
/// asserts what the code does now, so it is green now and fails the day the defect is fixed. The
/// fix changes behaviour and belongs to DMUnLoader 2.0; it flips the last assertion of each test.
///
/// The defect: a loading manager replaced by another loading manager is a change of content for
/// the accessibility coordinator. It tells VoiceOver that the screen changed and does not recompute
/// the windows that it hides, so the set of hidden windows stays the one of the level at which the
/// HUD appeared.
@MainActor
final class HUDAccessibilityHostedTests: XCTestCase {

    // MARK: - C-8.1

    /// Pins C-8.1: a window that was above the HUD and is under it once the new manager raises the
    /// level stays reachable. The fix hides it, and this test then fails.
    func test_replacingAShownManager_withOneAtAHigherLevel_pinsC81_theCoverNowUnderTheHUDStaysReachable() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        let cover = makeCover(in: scene, level: .normal + 1)
        let appWindow = try appWindow(in: scene)
        defer { restoreTheScreen(sceneDelegate, appWindow: appWindow, thenRemove: cover) }
        giveTheScreenBack(sceneDelegate, appWindow: appWindow)

        sceneDelegate.loadingManager = loadingManager(atLevel: .normal)
        let appWindowHiddenByTheFirstHUD = waitUntil(appWindow.accessibilityElementsHidden)
        let coverReachableAboveTheFirstHUD = !cover.accessibilityElementsHidden

        sceneDelegate.loadingManager = loadingManager(atLevel: .normal + 2)
        turnTheRunLoop(for: 1)
        let coverHiddenUnderTheNewHUD = cover.accessibilityElementsHidden

        XCTAssertTrue(appWindowHiddenByTheFirstHUD, "precondition: the first HUD hides the app window, which is under it")
        XCTAssertTrue(coverReachableAboveTheFirstHUD, "precondition: the cover is above the first HUD and reachable")
        XCTAssertFalse(
            coverHiddenUnderTheNewHUD,
            "C-8.1 as it is today: the cover is under the HUD of the new manager and stays reachable; the 2.0 fix hides it"
        )
    }

    /// Pins C-8.1 the other way: a window that was under the HUD and is above it once the new
    /// manager lowers the level stays hidden. The fix gives it back, and this test then fails.
    func test_replacingAShownManager_withOneAtALowerLevel_pinsC81_theCoverNowAboveTheHUDStaysHidden() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        let cover = makeCover(in: scene, level: .normal + 1)
        let appWindow = try appWindow(in: scene)
        defer { restoreTheScreen(sceneDelegate, appWindow: appWindow, thenRemove: cover) }
        giveTheScreenBack(sceneDelegate, appWindow: appWindow)

        sceneDelegate.loadingManager = loadingManager(atLevel: .normal + 2)
        let coverHiddenUnderTheFirstHUD = waitUntil(cover.accessibilityElementsHidden)

        sceneDelegate.loadingManager = loadingManager(atLevel: .normal)
        turnTheRunLoop(for: 1)
        let coverHiddenAboveTheNewHUD = cover.accessibilityElementsHidden

        XCTAssertTrue(coverHiddenUnderTheFirstHUD, "precondition: the first HUD hides the cover, which is under it")
        XCTAssertTrue(
            coverHiddenAboveTheNewHUD,
            "C-8.1 as it is today: the cover is above the HUD of the new manager and stays hidden; the 2.0 fix gives it back"
        )
    }

    // MARK: - Helpers

    /// A window of the scene above the app's own one, which a HUD at or above its level hides.
    private func makeCover(in scene: UIWindowScene, level: UIWindow.Level) -> UIWindow {
        let cover = UIWindow(windowScene: scene)
        cover.windowLevel = level
        cover.rootViewController = UIViewController()
        cover.isHidden = false
        return cover
    }

    private func appWindow(in scene: UIWindowScene) throws -> UIWindow {
        try XCTUnwrap(
            scene.windows.first { !hudWindows(in: scene).contains($0) && $0.windowLevel == .normal },
            "the app's own window"
        )
    }

    private func loadingManager(atLevel level: UIWindow.Level) -> DMLoadingManagerMain {
        DMLoadingManagerMain(
            state: .loading(provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider()),
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudWindowLevel: level)
        )
    }

    /// An idle manager, and the wait until the HUD has reported it and given the app window back.
    /// A test that starts before that can meet windows that the test before it left in the wrong
    /// state: a first version of these tests, which removed the cover before it set the idle manager,
    /// failed the precondition of its second test.
    private func giveTheScreenBack(_ sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>, appWindow: UIWindow) {
        sceneDelegate.loadingManager = DMLoadingManagerMain()
        _ = waitUntil(!appWindow.accessibilityElementsHidden)
    }

    /// The end of a test: the screen is given back while the cover is still in the scene, so that
    /// the HUD restores it too, and only then does the cover go.
    private func restoreTheScreen(
        _ sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>,
        appWindow: UIWindow,
        thenRemove cover: UIWindow
    ) {
        giveTheScreenBack(sceneDelegate, appWindow: appWindow)
        remove(cover)
    }

    /// A window that is not to change cannot be waited for, so the run loop turns for a fixed time.
    private func turnTheRunLoop(for seconds: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }
}
