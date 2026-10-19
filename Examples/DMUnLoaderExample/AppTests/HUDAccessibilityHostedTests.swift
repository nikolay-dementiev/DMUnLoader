import DMUnLoader
import UIKit
import XCTest

/// What the HUD hides from assistive technology while it stays on the screen and its manager is
/// replaced by one at another window level. Each test here pins a known defect as it is today: it
/// asserts what the code does now, so it is green now and fails the day the defect is fixed. The
/// fix changes behaviour; it flips the last assertion of each test.
///
/// The defect: a loading manager replaced by another loading manager is a change of content for
/// the accessibility coordinator. It tells VoiceOver that the screen changed and does not recompute
/// the windows that it hides, so the set of hidden windows stays the one of the level at which the
/// HUD appeared.
@MainActor
final class HUDAccessibilityHostedTests: XCTestCase {

    // MARK: - The windows hidden after a replacement at another level

    /// Pins the known defect: a window that was above the HUD and is under it once the new manager
    /// raises the level stays reachable. A fix hides it, and this test then fails.
    func test_shownManagerReplaced_atHigherLevel_coverUnderTheHUDStaysReachable_knownDefect() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        let appWindow = try findAppWindow(in: scene)
        let cover = makeCover(in: scene, level: .normal + 1)
        defer { restoreTheScreen(sceneDelegate, appWindow: appWindow, thenRemove: cover) }
        giveTheScreenBack(
            sceneDelegate,
            appWindow: appWindow,
            because: "precondition: the test starts with the app window reachable"
        )
        let newLevel = UIWindow.Level.normal + 2

        sceneDelegate.loadingManager = loadingManager(atLevel: .normal)
        let appWindowHiddenByTheFirstHUD = waitUntil(appWindow.accessibilityElementsHidden)
        let coverReachableAboveTheFirstHUD = !cover.accessibilityElementsHidden

        sceneDelegate.loadingManager = loadingManager(atLevel: newLevel)
        let levelOfTheHUDWindow = hudWindows(in: scene).first?.windowLevel
        turnTheRunLoop(for: 1)
        let coverHiddenUnderTheNewHUD = cover.accessibilityElementsHidden

        XCTAssertTrue(appWindowHiddenByTheFirstHUD, "precondition: the first HUD hides the app window, which is under it")
        XCTAssertTrue(coverReachableAboveTheFirstHUD, "precondition: the cover is above the first HUD and reachable")
        XCTAssertEqual(
            levelOfTheHUDWindow,
            newLevel,
            "precondition: the HUD window is at the level of the new manager, above the cover"
        )
        XCTAssertFalse(
            coverHiddenUnderTheNewHUD,
            "known defect as it is today: the cover is under the HUD of the new manager and stays reachable; a fix hides it"
        )
    }

    /// Pins the known defect the other way: a window that was under the HUD and is above it once the
    /// new manager lowers the level stays hidden. A fix gives it back, and this test then fails.
    func test_shownManagerReplaced_atLowerLevel_coverAboveTheHUDStaysHidden_knownDefect() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        let appWindow = try findAppWindow(in: scene)
        let cover = makeCover(in: scene, level: .normal + 1)
        defer { restoreTheScreen(sceneDelegate, appWindow: appWindow, thenRemove: cover) }
        giveTheScreenBack(
            sceneDelegate,
            appWindow: appWindow,
            because: "precondition: the test starts with the app window reachable"
        )
        let newLevel = UIWindow.Level.normal

        sceneDelegate.loadingManager = loadingManager(atLevel: .normal + 2)
        let coverHiddenUnderTheFirstHUD = waitUntil(cover.accessibilityElementsHidden)

        sceneDelegate.loadingManager = loadingManager(atLevel: newLevel)
        let levelOfTheHUDWindow = hudWindows(in: scene).first?.windowLevel
        turnTheRunLoop(for: 1)
        let coverHiddenAboveTheNewHUD = cover.accessibilityElementsHidden

        XCTAssertTrue(coverHiddenUnderTheFirstHUD, "precondition: the first HUD hides the cover, which is under it")
        XCTAssertEqual(
            levelOfTheHUDWindow,
            newLevel,
            "precondition: the HUD window is at the level of the new manager, under the cover"
        )
        XCTAssertTrue(
            coverHiddenAboveTheNewHUD,
            "known defect as it is today: the cover is above the HUD of the new manager and stays hidden; a fix gives it back"
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

    /// A manager that shows a loading, with a provider of its own: two providers are two states, so
    /// a manager replaced by another one reaches the accessibility coordinator as a change of content.
    private func loadingManager(atLevel level: UIWindow.Level) -> DMLoadingManagerMain {
        DMLoadingManagerMain(
            state: .loading(provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider()),
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudWindowLevel: level)
        )
    }

    /// An idle manager, and the wait until the HUD has reported it and given the app window back.
    /// A test that starts before that meets the windows in the state that the test before it left them in.
    private func giveTheScreenBack(
        _ sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>,
        appWindow: UIWindow,
        because reason: String
    ) {
        sceneDelegate.loadingManager = DMLoadingManagerMain()
        XCTAssertTrue(waitUntil(!appWindow.accessibilityElementsHidden), reason)
    }

    /// The end of a test: the screen is given back while the cover is still in the scene, so that
    /// the HUD restores it too, and only then does the cover go.
    private func restoreTheScreen(
        _ sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>,
        appWindow: UIWindow,
        thenRemove cover: UIWindow
    ) {
        giveTheScreenBack(
            sceneDelegate,
            appWindow: appWindow,
            because: "the idle manager gives the app window back before the cover goes"
        )
        remove(cover)
    }

    /// A window that is not to change cannot be waited for, so the run loop turns for a fixed time.
    private func turnTheRunLoop(for seconds: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }
}
