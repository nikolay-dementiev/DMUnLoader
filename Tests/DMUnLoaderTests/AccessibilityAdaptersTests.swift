//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest
import DMUnLoader

/// The two system adapters of the HUD's accessibility: what is hidden from assistive
/// technology while a HUD is shown, and whether a remembered element is still on screen.
@MainActor
final class AccessibilityAdaptersTests: XCTestCase {

    // MARK: - Content underneath

    func test_contentHider_hidesOtherWindowsOfTheSceneOnly() {
        let windows = SceneWindows()
        let sut = makeHider(for: windows)

        sut.hideContentUnderneath()

        XCTAssertTrue(windows.app.accessibilityElementsHidden, "a window at the level of the HUD is hidden")
        XCTAssertTrue(windows.below.accessibilityElementsHidden, "a window below the HUD is hidden")
        XCTAssertFalse(windows.above.accessibilityElementsHidden, "a window above the HUD stays reachable")
        XCTAssertFalse(windows.hud.accessibilityElementsHidden, "the HUD stays reachable")
    }

    func test_contentHider_restore_showsTheWindowsAgain() {
        let windows = SceneWindows()
        let sut = makeHider(for: windows)
        sut.hideContentUnderneath()

        sut.restoreContentUnderneath()

        XCTAssertFalse(windows.app.accessibilityElementsHidden, "the window at the level of the HUD is reachable again")
        XCTAssertFalse(windows.below.accessibilityElementsHidden, "the window below the HUD is reachable again")
    }

    func test_contentHider_restore_keepsAWindowTheHostHadHidden() {
        let windows = SceneWindows()
        windows.below.accessibilityElementsHidden = true
        let sut = makeHider(for: windows)
        sut.hideContentUnderneath()

        sut.restoreContentUnderneath()

        XCTAssertTrue(windows.below.accessibilityElementsHidden, "a window the host had hidden stays hidden")
    }

    // MARK: - Remembered element

    func test_announcer_viewInAWindow_isOnScreen() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let view = UIView()
        window.addSubview(view)

        XCTAssertTrue(SystemAccessibilityAnnouncer().isOnScreen(view))
    }

    func test_announcer_viewInNoWindow_isNotOnScreen() {
        XCTAssertFalse(SystemAccessibilityAnnouncer().isOnScreen(UIView()))
    }

    func test_announcer_elementOfAViewInNoWindow_isNotOnScreen() {
        let container = UIView()
        let element = UIAccessibilityElement(accessibilityContainer: container)

        XCTAssertFalse(SystemAccessibilityAnnouncer().isOnScreen(element))
    }

    // MARK: - Helpers

    /// The windows of a scene around a HUD window at the normal level.
    @MainActor
    private final class SceneWindows {
        let hud = UIWindow()
        let app = UIWindow()
        let below = UIWindow()
        let above = UIWindow()

        init() {
            hud.windowLevel = .normal
            app.windowLevel = .normal
            below.windowLevel = .normal - 1
            above.windowLevel = .normal + 1
        }

        var all: [UIWindow] {
            [hud, app, below, above]
        }
    }

    private func makeHider(for windows: SceneWindows) -> SceneContentHider {
        SceneContentHider(hudWindow: windows.hud) { windows.all }
    }
}
