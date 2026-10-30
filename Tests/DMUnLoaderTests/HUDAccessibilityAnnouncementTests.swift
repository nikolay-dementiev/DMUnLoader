//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader
import UIKit
import XCTest

/// What the HUD tells assistive technology, and when, in a real window of a window scene with an app
/// window under it: the notification that the screen changed when the HUD appears, when it shows another
/// state, and when it goes, with the view that had the focus before the HUD as the one to focus again.
///
/// The announcer is the real one with a recording `post`, so the order of what the HUD posts across the
/// windows is the real one. What the tests cannot see is what a screen reader does with a notification.
@MainActor
final class HUDAccessibilityAnnouncementTests: XCTestCase {

    // MARK: - Show

    func test_show_postsScreenChangedWithNoFocusOnceTheAppWindowIsHidden() {
        guard let sut = makeSUT() else { return }

        sut.presenter.present(sut.makeManager(state: sut.loading))

        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 1), "the HUD tells that the screen changed")
        XCTAssertEqual(sut.recorder.posts.count, 1, "it tells once: \(sut.recorder.summary)")
        XCTAssertTrue(sut.recorder.posts.first?.notification == .screenChanged, "the notification is screenChanged")
        XCTAssertNil(sut.recorder.posts.first?.argument, "it names no element, so the first element of the HUD is focused")
        XCTAssertEqual(
            sut.recorder.posts.first?.appWindowHidden,
            true,
            "when the notification goes out the app window is already hidden from assistive technology"
        )
    }

    // MARK: - Change of content

    func test_changeOfContent_postsScreenChangedAgainWhileTheAppWindowStaysHidden() {
        guard let sut = makeSUT() else { return }
        let manager = sut.makeManager(state: sut.loading)
        sut.presenter.present(manager)
        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 1), "the HUD told that the screen changed")

        manager.showSuccess("Saved", provider: sut.provider)

        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 2), "a new state tells that the screen changed")
        XCTAssertNil(sut.recorder.posts.last?.argument, "the change of content names no element")
        XCTAssertEqual(
            sut.recorder.posts.last?.appWindowHidden,
            true,
            "the app window stays hidden while the HUD shows another state: \(sut.recorder.summary)"
        )
    }

    // MARK: - Hide

    func test_hide_postsScreenChangedFocusingTheViewThatHadTheFocusAfterTheAppWindowIsBack() {
        guard let sut = makeSUT() else { return }
        let manager = sut.makeManager(state: sut.loading)
        sut.presenter.present(manager)
        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 1), "the HUD told that the screen changed")

        manager.hide()

        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 2), "the HUD tells that the screen changed again")
        XCTAssertTrue(
            sut.recorder.posts.last?.argument === sut.appView,
            "the focus goes back to the view that had it before the HUD: \(sut.recorder.summary)"
        )
        XCTAssertEqual(
            sut.recorder.posts.last?.appWindowHidden,
            false,
            "when the notification goes out the app window is reachable again"
        )
    }

    func test_hide_whenTheViewThatHadTheFocusIsGone_postsScreenChangedWithNoFocus() {
        guard let sut = makeSUT() else { return }
        let manager = sut.makeManager(state: sut.loading)
        sut.presenter.present(manager)
        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 1), "the HUD told that the screen changed")
        sut.appView.removeFromSuperview()

        manager.hide()

        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 2), "the HUD tells that the screen changed again")
        XCTAssertNil(
            sut.recorder.posts.last?.argument,
            "a view that left the screen is not focused again: \(sut.recorder.summary)"
        )
    }

    // MARK: - The whole sequence

    func test_showChangeAndHide_postScreenChangedThreeTimesInOrder() {
        guard let sut = makeSUT() else { return }
        let manager = sut.makeManager(state: sut.loading)

        sut.presenter.present(manager)
        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 1), "the HUD told that the screen changed")
        manager.showSuccess("Saved", provider: sut.provider)
        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 2), "the new state told it again")
        manager.hide()
        XCTAssertTrue(turnRunLoop(until: sut.recorder.posts.count >= 3), "the hide told it a third time")
        turnRunLoop(for: 0.3)

        XCTAssertEqual(
            sut.recorder.summary,
            """
            screenChanged(nil, appWindowHidden: true), screenChanged(nil, appWindowHidden: true), \
            screenChanged(appView, appWindowHidden: false)
            """,
            "show, change of content, hide: the notifications in the order they go out, and what the app window was at each"
        )
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT? {
        let probe = UIWindow(frame: UIScreen.main.bounds)
        guard let scene = probe.windowScene else {
            XCTFail("A window made by UIWindow(frame:) belongs to no window scene.", file: file, line: line)
            return nil
        }
        let sut = SUT(scene: scene, probe: probe)
        addTeardownBlock { [weak sut] in
            sut?.remove()
        }
        return sut
    }
}

/// The notifications that the HUD posted, and what the app window was when each went out.
@MainActor
private final class AnnouncementRecorder {
    struct Post {
        let notification: UIAccessibility.Notification
        let argument: AnyObject?
        let appWindowHidden: Bool
    }

    private(set) var posts: [Post] = []
    weak var appWindow: UIWindow?
    weak var appView: UIView?

    func record(_ notification: UIAccessibility.Notification, _ argument: Any?) {
        posts.append(Post(
            notification: notification,
            argument: argument as AnyObject?,
            appWindowHidden: appWindow?.accessibilityElementsHidden ?? false
        ))
    }

    var summary: String {
        posts.map { post in
            let name = post.notification == .screenChanged ? "screenChanged" : "other"
            let argument = post.argument == nil ? "nil" : (post.argument === appView ? "appView" : "another object")
            return "\(name)(\(argument), appWindowHidden: \(post.appWindowHidden))"
        }.joined(separator: ", ")
    }
}

/// An app window with a view that has the focus, a recording announcer, and the real presenter.
@MainActor
private final class SUT {
    let recorder = AnnouncementRecorder()
    let appWindow: UIWindow
    let appView = UIView()
    let presenter: OverlayWindowPresenter
    let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
    private let probe: UIWindow

    var loading: DMLoadableType {
        .loading(provider: provider)
    }

    init(scene: UIWindowScene, probe: UIWindow) {
        self.probe = probe
        appWindow = UIWindow(windowScene: scene)
        appWindow.rootViewController = UIViewController()
        appWindow.isHidden = false
        appWindow.rootViewController?.view.addSubview(appView)
        recorder.appWindow = appWindow
        recorder.appView = appView
        let recorder = recorder
        let appView = appView
        presenter = OverlayWindowPresenter(
            windowScene: scene,
            announcer: SystemAccessibilityAnnouncer(
                post: { notification, argument in recorder.record(notification, argument) },
                focusedElement: { appView }
            )
        )
    }

    func makeManager(state: DMLoadableType) -> DMLoadingManagerMain {
        DMLoadingManagerMain(state: state, settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600)))
    }

    func remove() {
        presenter.dismiss()
        appWindow.isHidden = true
        probe.isHidden = true
    }
}
