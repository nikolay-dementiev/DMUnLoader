import DMUnLoader
import UIKit
import XCTest

/// What the HUD hides from assistive technology while it stays on the screen and its manager is
/// replaced by one at another window level.
///
/// The HUD hides the windows of its scene that are at or under its own level. A replacement that
/// moves the level moves that set: a window that is under the new level is hidden, and one that
/// is above it is given back. It does not matter whether the new manager shows another state or
/// the very same one.
@MainActor
final class HUDAccessibilityHostedTests: XCTestCase {

    // MARK: - The windows hidden after a replacement at another level

    /// A window that was above the HUD and is under it once the new manager raises the level is hidden.
    func test_shownManagerReplaced_atHigherLevel_coverUnderTheHUDIsHidden() throws {
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
        let coverHiddenUnderTheNewHUD = waitUntil(cover.accessibilityElementsHidden)

        XCTAssertTrue(appWindowHiddenByTheFirstHUD, "precondition: the first HUD hides the app window, which is under it")
        XCTAssertTrue(coverReachableAboveTheFirstHUD, "precondition: the cover is above the first HUD and reachable")
        XCTAssertEqual(
            levelOfTheHUDWindow,
            newLevel,
            "precondition: the HUD window is at the level of the new manager, above the cover"
        )
        XCTAssertTrue(
            coverHiddenUnderTheNewHUD,
            "the cover is under the HUD of the new manager, so the HUD hides it"
        )
    }

    /// The same replacement when the new manager shows the very same state: the state does not
    /// change, so the level is the only thing that tells the HUD to hide the cover.
    func test_shownManagerReplaced_withTheSameStateAtHigherLevel_coverUnderTheHUDIsHidden() throws {
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
        let provider = DefaultDMLoadingViewProvider()

        sceneDelegate.loadingManager = loadingManager(atLevel: .normal, provider: provider)
        let appWindowHiddenByTheFirstHUD = waitUntil(appWindow.accessibilityElementsHidden)
        let coverReachableAboveTheFirstHUD = !cover.accessibilityElementsHidden

        sceneDelegate.loadingManager = loadingManager(atLevel: newLevel, provider: provider)
        let levelOfTheHUDWindow = hudWindows(in: scene).first?.windowLevel
        let coverHiddenUnderTheNewHUD = waitUntil(cover.accessibilityElementsHidden)

        XCTAssertTrue(appWindowHiddenByTheFirstHUD, "precondition: the first HUD hides the app window, which is under it")
        XCTAssertTrue(coverReachableAboveTheFirstHUD, "precondition: the cover is above the first HUD and reachable")
        XCTAssertEqual(
            levelOfTheHUDWindow,
            newLevel,
            "precondition: the HUD window is at the level of the new manager, above the cover"
        )
        XCTAssertTrue(
            coverHiddenUnderTheNewHUD,
            "the cover is under the HUD of the new manager, which shows the same state, so the HUD hides it"
        )
    }

    /// A window that was under the HUD and is above it once the new manager lowers the level is given back.
    func test_shownManagerReplaced_atLowerLevel_coverAboveTheHUDIsGivenBack() throws {
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
        let coverGivenBackAboveTheNewHUD = waitUntil(!cover.accessibilityElementsHidden)

        XCTAssertTrue(coverHiddenUnderTheFirstHUD, "precondition: the first HUD hides the cover, which is under it")
        XCTAssertEqual(
            levelOfTheHUDWindow,
            newLevel,
            "precondition: the HUD window is at the level of the new manager, under the cover"
        )
        XCTAssertTrue(
            coverGivenBackAboveTheNewHUD,
            "the cover is above the HUD of the new manager, so the HUD gives it back"
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

    /// A manager that shows a loading. Without a `provider` it gets one of its own: two providers
    /// are two states, so a manager replaced by another one is a change of content. Managers given
    /// one provider show the same state.
    private func loadingManager(
        atLevel level: UIWindow.Level,
        provider: DefaultDMLoadingViewProvider = DefaultDMLoadingViewProvider()
    ) -> DMLoadingManagerMain {
        DMLoadingManagerMain(
            state: .loading(provider: provider.eraseToAnyViewProvider()),
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
}
