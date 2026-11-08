//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
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
        guard let sut = makeSUT(
            state: Self.success,
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .milliseconds(10)),
            announcer: announcer
        ) else { return }
        XCTAssertTrue(
            turnRunLoop(until: announcer.events.contains(.screenChanged(focusing: nil))),
            "the view of the HUD reported the success to the window"
        )

        // The one wait of fixed length in these tests, and it is bounded on purpose: the presenter has no
        // scheduler to give it, and a presenter that behaves hides nothing, so there is no event to wait
        // for. A presenter that hid on a clock would do it within the 10 ms of the delay. A machine that
        // stalls for more than this wait would miss such a presenter; it can never fail a correct one.
        turnRunLoop(for: 0.3)

        XCTAssertEqual(sut.manager.hideCount, 0, "a manager of the host's own is hidden by the host, never by the presenter")
        XCTAssertEqual(sut.manager.loadableState.phase, .success, "the success is still shown after the delay of its settings")
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

        let handled = sut.window?.accessibilityPerformEscape()
        let tapOutsideTheCard = DefaultHUDViewModel(loadingManager: sut.manager).backdropTapped()

        XCTAssertEqual(sut.manager.hideCount, 0, "the escape does what a tap outside the card does: the rule says no hide")
        XCTAssertEqual(handled, false, "the escape reports that the HUD stayed")
        XCTAssertEqual(tapOutsideTheCard, handled, "a tap outside the card gives the same answer as the escape")
    }

    // MARK: - Helpers

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
        return Fixture(manager: manager, scene: scene)
    }
}
