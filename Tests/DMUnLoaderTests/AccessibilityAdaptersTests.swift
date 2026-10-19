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

    func test_contentHider_hiddenTwice_restoredOnce_givesTheWindowsBack() {
        let windows = SceneWindows()
        let sut = makeHider(for: windows)
        sut.hideContentUnderneath()
        sut.hideContentUnderneath()

        sut.restoreContentUnderneath()

        XCTAssertFalse(windows.app.accessibilityElementsHidden, "one restore gives back what two hides of one HUD took")
    }

    func test_contentHider_twoHUDsOverlap_giveTheWindowBackWhenTheLastGoes() {
        let windows = SceneWindows()
        let secondHUD = UIWindow()
        secondHUD.windowLevel = .normal
        let first = makeHider(for: windows)
        let second = SceneContentHider(hudWindow: secondHUD) { windows.all + [secondHUD] }
        first.hideContentUnderneath()
        second.hideContentUnderneath()

        first.restoreContentUnderneath()
        let hiddenWhileTheSecondIsShown = windows.app.accessibilityElementsHidden
        second.restoreContentUnderneath()

        XCTAssertTrue(hiddenWhileTheSecondIsShown, "the window stays hidden while another HUD still hides it")
        XCTAssertFalse(windows.app.accessibilityElementsHidden, "the window comes back when the last HUD goes")
    }

    func test_contentHider_anotherHUDWindow_staysReachable() {
        let windows = SceneWindows()
        let otherHUD = DMPassThroughWindow(frame: .zero)
        otherHUD.windowLevel = .normal
        let sut = SceneContentHider(hudWindow: windows.hud) { windows.all + [otherHUD] }

        sut.hideContentUnderneath()

        XCTAssertFalse(otherHUD.accessibilityElementsHidden, "the window of another HUD is not content under this one")
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

    // MARK: - Remembered element that nobody can see (C-8.2)

    // The four tests below pin C-8.2 as it is today: `isOnScreen` tells whether a view is attached to a
    // window, not whether anyone can see it. Each asserts what the code does now, so each is green now
    // and fails the day the defect is fixed. The fix changes behaviour and belongs to DMUnLoader 2.0;
    // it flips the last assertion of each test.

    func test_announcer_hiddenView_pinsC82_isStillOnScreen() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let view = UIView()
        window.addSubview(view)
        view.isHidden = true

        XCTAssertTrue(
            SystemAccessibilityAnnouncer().isOnScreen(view),
            "C-8.2 as it is today: a hidden view counts as on screen; the 2.0 fix makes it not"
        )
    }

    func test_announcer_childOfAHiddenView_pinsC82_isStillOnScreen() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let parent = UIView()
        let child = UIView()
        window.addSubview(parent)
        parent.addSubview(child)
        parent.isHidden = true

        XCTAssertTrue(
            SystemAccessibilityAnnouncer().isOnScreen(child),
            "C-8.2 as it is today: the child of a hidden view counts as on screen; the 2.0 fix makes it not"
        )
    }

    func test_announcer_viewInAHiddenWindow_pinsC82_isStillOnScreen() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let view = UIView()
        window.addSubview(view)
        window.isHidden = true

        XCTAssertTrue(
            SystemAccessibilityAnnouncer().isOnScreen(view),
            "C-8.2 as it is today: a view in a hidden window counts as on screen; the 2.0 fix makes it not"
        )
    }

    func test_coordinator_hudGoes_theRememberedViewIsHidden_pinsC82_theFocusStillReturnsToIt() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let view = UIView()
        window.addSubview(view)
        let (sut, announcer) = makeCoordinator(focusing: view)
        sut.stateDidChange(to: .loading, identifiedBy: "loading")
        view.isHidden = true

        sut.stateDidChange(to: .none, identifiedBy: "none")

        XCTAssertEqual(
            announcer.screenChanges,
            [nil, ObjectIdentifier(view)],
            "C-8.2 as it is today: the focus returns to the hidden view; the 2.0 fix posts the change with no element"
        )
    }

    @MainActor
    func test_announcer_screenChanged_postsTheElementOnALaterTurn() async {
        let posted = PostedNotifications()
        let element = NSObject()
        let sut = SystemAccessibilityAnnouncer { notification, argument in
            posted.record(notification, argument as AnyObject?)
        }

        sut.screenChanged(focusing: element)

        XCTAssertTrue(posted.isEmpty, "nothing is posted within the call: the HUD window changes in this turn")
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while posted.isEmpty, Date() < deadline {
            await Task.yield()
        }
        XCTAssertEqual(
            posted.notifications,
            [.screenChanged],
            "the screen change is posted once, as a screen-changed notification"
        )
        XCTAssertTrue(posted.argument === element, "the notification carries the element to focus")
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

    private func makeCoordinator(
        focusing view: UIView,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: HUDAccessibilityCoordinator, announcer: FocusHoldingAnnouncer) {
        let announcer = FocusHoldingAnnouncer(focusing: view)
        let sut = HUDAccessibilityCoordinator(announcer: announcer, contentHider: AccessibilitySpy())
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, announcer)
    }
}

/// An announcer for a coordinator that is to meet the real `isOnScreen`: assistive technology
/// holds its focus on a view of the test, the question whether that view is on screen goes to the
/// adapter that the HUD uses, and the screen changes are recorded with the element they focus.
@MainActor
private final class FocusHoldingAnnouncer: AccessibilityAnnouncer {
    private let focus: AnyObject
    private let adapter = SystemAccessibilityAnnouncer { _, _ in }
    private(set) var screenChanges: [ObjectIdentifier?] = []

    init(focusing element: AnyObject) {
        self.focus = element
    }

    var focusedElement: AnyObject? {
        focus
    }

    func isOnScreen(_ element: AnyObject) -> Bool {
        adapter.isOnScreen(element)
    }

    func screenChanged(focusing element: AnyObject?) {
        screenChanges.append(element.map(ObjectIdentifier.init))
    }
}

/// What the announcer posted: each notification, and the argument of the last one.
@MainActor
private final class PostedNotifications {
    private(set) var notifications: [UIAccessibility.Notification] = []
    private(set) var argument: AnyObject?

    var isEmpty: Bool {
        notifications.isEmpty
    }

    func record(_ notification: UIAccessibility.Notification, _ argument: AnyObject?) {
        notifications.append(notification)
        self.argument = argument
    }
}
