//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit
import ViewInspector
import XCTest
import DMUnLoader

/// The real presenter over a real window scene, with a loading manager of the host's own. The package tests
/// run with no connected scene; a window made by `UIWindow(frame:)` belongs to a scene of its own, which
/// the presenter uses as it uses the scene of an app. No accessibility automation is on: the tests read
/// what the manager is asked and what the announcer is told, not the accessibility tree.
@MainActor
final class OverlayWindowPresenterTests: XCTestCase {

    // MARK: - Who hides

    func test_hostManagerInASuccess_withATinyAutoHideDelay_isNeverHiddenByThePresenter() {
        let announcer = AccessibilitySpy()
        // This manager clears its state when it is asked to hide, so a hide by the presenter would show in the
        // state as well as in the count.
        guard let sut = makeSUT(
            state: Self.success,
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .milliseconds(10)),
            hideClearsState: true,
            announcer: announcer
        ) else { return }
        XCTAssertTrue(
            turnRunLoop(until: announcer.events.contains(.screenChanged(focusing: nil)), timeout: TestTiming.callbackAllowance),
            "the view of the HUD reported the success to the window"
        )

        // The one wait of fixed length in these tests, and it is bounded on purpose: the presenter has no
        // scheduler to give it, and a presenter that behaves hides nothing, so there is no event to wait
        // for. A presenter that hid on a clock would do it within the 10 ms of the delay. A machine that
        // stalls for more than this wait would miss such a presenter; it can never fail a correct one.
        turnRunLoop(for: 0.3)

        XCTAssertEqual(sut.manager.hideCount, 0, "a manager of the host's own is hidden by the host, never by the presenter")
        XCTAssertEqual(sut.manager.loadableState.phase, .success, "the success is still shown, as a hide would have cleared it")
        // The control: the manager is attached, and the one way the window hides a HUD reaches it.
        _ = sut.window?.accessibilityPerformEscape()
        XCTAssertEqual(sut.manager.hideCount, 1, "the escape of the HUD window asks the manager to hide, once")
    }

    // MARK: - The escape of the HUD window

    func test_escape_onARefusingManager_asksItToHideExactlyOnce() {
        guard let sut = makeSUT(state: Self.success, settings: Self.settings(), announcer: AccessibilitySpy()) else { return }

        let handled = sut.window?.accessibilityPerformEscape()

        XCTAssertEqual(sut.manager.hideCount, 1, "the escape asks the manager once to hide the success")
        XCTAssertEqual(handled, false, "the success is still shown after the call, so the escape reports that it did not go")
    }

    func test_escape_whenTheBackdropRuleRefuses_asksForNoHideAndReportsThatTheHUDStayed() {
        let rules = DMHUDDismissalRules(success: DMHUDDismissal(backdropTapHides: false))
        guard let sut = makeSUT(
            state: Self.success,
            settings: Self.settings(hudDismissal: rules),
            announcer: AccessibilitySpy()
        ) else { return }

        // That the window has an escape handler at all is shown by the two tests above, which see the manager
        // asked to hide; without a handler this test would see no hide either.
        let handled = sut.window?.accessibilityPerformEscape()
        let tapOutsideTheCard = DefaultHUDViewModel(model: LoadingManagerHUDModel(sut.manager)).backdropTapped()

        XCTAssertEqual(sut.manager.hideCount, 0, "the escape does what a tap outside the card does: the rule says no hide")
        XCTAssertEqual(handled, false, "the escape reports that the HUD stayed")
        XCTAssertEqual(tapOutsideTheCard, handled, "a tap outside the card gives the same answer as the escape")
    }

    // MARK: - The lifetime of a replaced manager

    func test_escapeHandler_ofAReplacedManager_keepsNoManagerAlive() {
        var shownFirst: Fixture? = makeSUT(state: Self.success, settings: Self.settings(), announcer: AccessibilitySpy())
        guard let presenter = shownFirst?.presenter, let handlerOfFirst = shownFirst?.window?.escapeHandler else {
            XCTFail("The first HUD has a presenter and a window with an escape handler.")
            return
        }
        // A capture list holds it weakly: `weak let` needs Swift 6.3, and a `weak var` that nothing assigns warns.
        let firstIsReleased = { [weak first = shownFirst?.manager] in first == nil }

        // A second manager takes over the window: its root view replaces that of the first, and its
        // escape handler replaces the first one. The test still holds the handler of the first.
        presenter.present(HostLoadingManagerSpy())
        shownFirst = nil

        // The wait ends on a positive signal, the release itself, so there is no fixed length to outlast:
        // a manager that nothing holds is gone in the first turns of the run loop. A handler that held it
        // would run the wait to its limit and fail the test. Only a machine stalled for the whole limit
        // could fail a correct handler.
        let released = turnRunLoop(until: firstIsReleased(), timeout: TestTiming.callbackAllowance)

        XCTAssertTrue(released, "the escape handler of the window held the manager that the window had replaced")
        XCTAssertFalse(handlerOfFirst(), "the handler of a manager that is gone reports that nothing went")
    }

    // MARK: - The root view of the window

    func test_rootView_appliesTheSystemAccessibilitySettings() throws {
        guard let sut = makeSUT(state: Self.success, settings: Self.settings(), announcer: AccessibilitySpy()),
              let hosting = sut.window?.rootViewController as? UIHostingController<AnyView> else {
            XCTFail("The HUD window has a hosting controller of an AnyView.")
            return
        }

        let sceneView = try hosting.rootView.inspect().anyView().view(DMHudSceneView<HostLoadingManagerSpy>.self)

        XCTAssertNoThrow(
            try sceneView.modifier(SystemAccessibilitySettings.self),
            "the view in the window takes Reduce Motion and Reduce Transparency from the system"
        )
    }

    // MARK: - A HUD that comes after a dismiss

    func test_present_afterADismiss_hidesTheContentUnderTheNewWindow() {
        // The frame does not matter: the HUD takes the size of the scene, not of this window.
        let probe = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        guard let scene = probe.windowScene else {
            XCTFail("A window made by UIWindow(frame:) belongs to no window scene.")
            return
        }
        let appWindow = UIWindow(windowScene: scene)
        appWindow.isHidden = false
        let presenter = OverlayWindowPresenter(windowScene: scene, announcer: AccessibilitySpy())
        addTeardownBlock {
            presenter.dismiss()
            appWindow.isHidden = true
            probe.isHidden = true
        }
        presenter.present(HostLoadingManagerSpy(loadableState: Self.success, settings: Self.settings()))
        // The view of the HUD delivers its state after the window is made, so the hide comes a turn later.
        XCTAssertTrue(
            turnRunLoop(until: appWindow.accessibilityElementsHidden, timeout: TestTiming.callbackAllowance),
            "the first HUD hid the window under it from assistive technology"
        )
        presenter.dismiss()
        XCTAssertFalse(appWindow.accessibilityElementsHidden, "the window is reachable again once the HUD is gone")

        presenter.present(HostLoadingManagerSpy(loadableState: Self.success, settings: Self.settings()))

        // The wait ends on the hide itself. A coordinator that stayed bound to the window that went hides
        // the windows of a scene that window has left, which are none, so the wait would run to its limit.
        XCTAssertTrue(
            turnRunLoop(until: appWindow.accessibilityElementsHidden, timeout: TestTiming.callbackAllowance),
            "the HUD that came after a dismiss hid the window under it from assistive technology"
        )
    }

    // MARK: - What the HUD announces for a state that changes

    func test_anotherFailureInTheSamePhase_postsScreenChangedAgain() {
        let announcer = AccessibilitySpy()
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
        guard let sut = makeSUT(
            state: .failure(error: PresenterTestFailure.first, provider: provider, onRetry: nil),
            settings: Self.settings(),
            announcer: announcer
        ) else { return }
        XCTAssertTrue(
            turnRunLoop(until: Self.screenChangedCount(of: announcer) == 1, timeout: TestTiming.callbackAllowance),
            "the first failure was announced"
        )

        sut.manager.set(.failure(error: PresenterTestFailure.second, provider: provider, onRetry: nil))

        // Another error under one provider is another content in the same phase, and the screen changed.
        XCTAssertTrue(
            turnRunLoop(until: Self.screenChangedCount(of: announcer) == 2, timeout: TestTiming.callbackAllowance),
            "another failure in the same phase was announced again"
        )
    }

    func test_managerOfAnotherType_withAnEqualState_announcesNothingMore() {
        let announcer = AccessibilitySpy()
        let state = Self.success
        guard let sut = makeSUT(state: state, settings: Self.settings(), announcer: announcer),
              let window = sut.window else { return }
        XCTAssertTrue(
            turnRunLoop(until: Self.screenChangedCount(of: announcer) == 1, timeout: TestTiming.callbackAllowance),
            "the first HUD was announced"
        )
        let eventsOfTheFirst = announcer.events

        // A manager of another type is another view in the window, so the view delivers its state once as
        // it appears, equal or not. A manager of the same type is the same view and delivers nothing for an
        // equal state, so there is nothing to wait for and it is not tried here.
        sut.presenter.present(DMLoadingManagerMain(state: state, settings: Self.settings()))
        // The closure of the presenter that the view calls sets this flag and then tells the coordinator, in
        // one call on the main thread. The flag is set to false here, so it is true again only when the view
        // delivered its state, and the coordinator has been told by then. The wait ends on that delivery:
        // there is no fixed length to outlast, and no delivery that arrives later than the check.
        window.interceptsTouches = false
        let delivered = turnRunLoop(until: window.interceptsTouches, timeout: TestTiming.callbackAllowance)

        XCTAssertTrue(delivered, "the view of the manager of the other type delivered its state to the window")
        XCTAssertEqual(announcer.events, eventsOfTheFirst, "a state equal to the one shown is no change of content")
    }

    // MARK: - Helpers

    private static func screenChangedCount(of announcer: AccessibilitySpy) -> Int {
        announcer.events.filter { $0 == .screenChanged(focusing: nil) }.count
    }

    private static var success: DMLoadableType {
        .success("Saved", provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider())
    }

    private static func settings(hudDismissal: DMHUDDismissalRules = DMHUDDismissalRules()) -> DMLoadingManagerDefaultSettings {
        DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudDismissal: hudDismissal)
    }

    @MainActor
    private struct Fixture {
        let manager: HostLoadingManagerSpy
        let scene: UIWindowScene
        let presenter: OverlayWindowPresenter

        var window: DMPassThroughWindow? {
            scene.windows.compactMap { $0 as? DMPassThroughWindow }.first
        }
    }

    /// The real presenter, showing a manager of the host's own over the scene of a bare window. The test
    /// gets `nil` when it has failed already: the window belongs to no scene.
    ///
    /// The manager is not checked for a leak: on the scene of a bare window the HUD window, its controller
    /// and the manager of the last HUD outlive `dismiss()` for seconds, although the window has left its scene.
    private func makeSUT(
        state: DMLoadableType,
        settings: any DMLoadingManagerSettings,
        hideClearsState: Bool = false,
        announcer: AccessibilitySpy,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Fixture? {
        // The frame does not matter: the HUD takes the size of the scene, not of this window.
        let probe = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        guard let scene = probe.windowScene else {
            XCTFail("A window made by UIWindow(frame:) belongs to no window scene.", file: file, line: line)
            return nil
        }
        let manager = HostLoadingManagerSpy(loadableState: state, settings: settings, hideClearsState: hideClearsState)
        let presenter = OverlayWindowPresenter(windowScene: scene, announcer: announcer)
        presenter.present(manager)
        // The presenter is held strongly on purpose: a weak reference would be gone when the test method
        // returns, and the HUD window would stay in its scene.
        addTeardownBlock {
            presenter.dismiss()
            probe.isHidden = true
            XCTAssertTrue(
                scene.windows.compactMap { $0 as? DMPassThroughWindow }.isEmpty,
                "the HUD window left its scene when the test ended",
                file: file,
                line: line
            )
        }
        return Fixture(manager: manager, scene: scene, presenter: presenter)
    }
}

private enum PresenterTestFailure: Error {
    case first
    case second
}
