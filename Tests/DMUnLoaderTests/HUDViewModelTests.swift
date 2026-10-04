//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The view model of the HUD view: what it shows comes from the manager whenever it is read,
/// and what a touch does goes through the manager.
@MainActor
final class HUDViewModelTests: XCTestCase {

    func test_showsHUD_followsTheManager_afterTheViewModelWasMade() {
        let (sut, manager) = makeSUT()
        let shownBefore = sut.showsHUD

        manager.showLoading(provider: DefaultDMLoadingViewProvider())

        XCTAssertFalse(shownBefore, "no HUD while the manager has no state")
        XCTAssertTrue(sut.showsHUD, "a HUD once the manager shows the loading state, without a new view model")
    }

    func test_cardAndBackdropTap_onASuccess_hideIt() {
        for tap in Tap.allCases {
            let (sut, manager) = makeSUT()
            manager.showSuccess("done", provider: DefaultDMLoadingViewProvider())

            tap.send(to: sut)

            XCTAssertEqual(manager.loadableState, .none, "a tap on the \(tap) dismisses a success")
        }
    }

    func test_cardAndBackdropTap_onAFailure_hideIt() {
        for tap in Tap.allCases {
            let (sut, manager) = makeSUT()
            manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider(), onRetry: nil)

            tap.send(to: sut)

            XCTAssertEqual(manager.loadableState, .none, "a tap on the \(tap) dismisses a failure")
        }
    }

    func test_cardAndBackdropTap_whileLoading_keepTheLoadingState() {
        for tap in Tap.allCases {
            let (sut, manager) = makeSUT()
            manager.showLoading(provider: DefaultDMLoadingViewProvider())

            tap.send(to: sut)

            XCTAssertTrue(manager.loadableState.showsHUD, "a tap on the \(tap) does not dismiss the loading state")
        }
    }

    func test_cardTapped_cardRuleOff_keepsTheHUD() {
        let rules = DMHUDDismissalRules(
            success: DMHUDDismissal(cardTapHides: false),
            failureWithoutRetry: DMHUDDismissal(cardTapHides: false),
            failureWithRetry: DMHUDDismissal(cardTapHides: false)
        )
        for show in Show.allCases {
            let (sut, manager) = makeSUT(rules: rules)
            show.send(to: manager)

            sut.cardTapped()

            XCTAssertTrue(manager.loadableState.showsHUD, "a tap on the card keeps \(show) when its rule says so")
        }
    }

    func test_backdropTapped_backdropRuleOff_keepsTheHUD() {
        let rules = DMHUDDismissalRules(
            success: DMHUDDismissal(backdropTapHides: false),
            failureWithoutRetry: DMHUDDismissal(backdropTapHides: false),
            failureWithRetry: DMHUDDismissal(backdropTapHides: false)
        )
        for show in Show.allCases {
            let (sut, manager) = makeSUT(rules: rules)
            show.send(to: manager)

            let hid = sut.backdropTapped()

            XCTAssertTrue(manager.loadableState.showsHUD, "a tap outside the card keeps \(show) when its rule says so")
            XCTAssertFalse(hid, "the view model reports that \(show) stayed")
        }
    }

    func test_backdropTapped_onASuccess_reportsThatTheHUDWent() {
        let (sut, manager) = makeSUT()
        manager.showSuccess("done", provider: DefaultDMLoadingViewProvider())

        XCTAssertTrue(sut.backdropTapped(), "a tap outside the card that hides the HUD reports it")
    }

    func test_backdropTapped_customManager_followsItsSettings() {
        let rules = DMHUDDismissalRules(success: DMHUDDismissal(backdropTapHides: false))
        let manager = StubDMLoadingManager(
            loadableState: .success("done", provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider()),
            settings: DMLoadingManagerDefaultSettings(hudDismissal: rules)
        )
        let sut = DefaultHUDViewModel(loadingManager: manager)

        sut.backdropTapped()

        XCTAssertTrue(manager.loadableState.showsHUD, "a manager of the host's own keeps the success when its settings say so")
    }

    func test_backdropTapped_aManagerWhoseHideKeepsItsState_reportsThatTheHUDStayed() {
        let manager = HideKeepingManagerSpy(
            loadableState: .success("done", provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider())
        )
        let sut = DefaultHUDViewModel(loadingManager: manager)

        let hid = sut.backdropTapped()

        XCTAssertEqual(manager.hideCount, 1, "the tap asks the manager to hide the success")
        XCTAssertFalse(hid, "the success is still shown after the call, so the tap reports that the HUD stayed")
    }

    func test_cardAndBackdropTap_withNoState_askTheManagerForNothing() {
        let manager = HideKeepingManagerSpy()
        let sut = DefaultHUDViewModel(loadingManager: manager)

        sut.cardTapped()
        let hid = sut.backdropTapped()

        XCTAssertEqual(manager.hideCount, 0, "with no state a tap has nothing to hide and asks the manager for nothing")
        XCTAssertFalse(hid, "with no state a tap outside the card reports that nothing went")
    }

    func test_closeTapped_onAFailure_hidesIt() {
        let (sut, manager) = makeSUT()
        manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider(), onRetry: nil)

        sut.closeTapped()

        XCTAssertEqual(manager.loadableState, .none, "Close hides the failure")
    }

    // MARK: - Helpers

    /// A loading manager of the host's own that records `hide()` and keeps the state it has.
    @MainActor
    private final class HideKeepingManagerSpy: DMLoadingManager {
        let settings: any DMLoadingManagerSettings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
        @Published private(set) var loadableState: DMLoadableType
        private(set) var hideCount = 0

        init(loadableState: DMLoadableType) {
            self.loadableState = loadableState
        }

        init() {
            self.loadableState = .none
        }

        func showLoading<PR: DMLoadingViewProvider>(provider: PR) {}
        func showSuccess<PR: DMLoadingViewProvider>(_ message: any DMLoadableTypeSuccess, provider: PR) {}
        func showFailure<PR: DMLoadingViewProvider>(_ error: any Error, provider: PR, onRetry: (any DMAction)?) {}

        func hide() {
            hideCount += 1
        }
    }

    private enum Tap: CaseIterable, CustomStringConvertible {
        case card
        case backdrop

        var description: String {
            self == .card ? "card" : "backdrop"
        }

        @MainActor
        func send(to viewModel: DefaultHUDViewModel<DMLoadingManagerMain>) {
            switch self {
            case .card:
                viewModel.cardTapped()
            case .backdrop:
                viewModel.backdropTapped()
            }
        }
    }

    private enum Show: CaseIterable, CustomStringConvertible {
        case success
        case failureWithoutRetry
        case failureWithRetry

        var description: String {
            switch self {
            case .success: "a success"
            case .failureWithoutRetry: "a failure without Retry"
            case .failureWithRetry: "a failure with Retry"
            }
        }

        @MainActor
        func send(to manager: DMLoadingManagerMain) {
            let provider = DefaultDMLoadingViewProvider()
            switch self {
            case .success:
                manager.showSuccess("done", provider: provider)
            case .failureWithoutRetry:
                manager.showFailure(DMAppError.custom("failed"), provider: provider, onRetry: nil)
            case .failureWithRetry:
                manager.showFailure(DMAppError.custom("failed"), provider: provider, onRetry: DMButtonAction {})
            }
        }
    }

    private func makeSUT(
        rules: DMHUDDismissalRules = DMHUDDismissalRules(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: DefaultHUDViewModel<DMLoadingManagerMain>, manager: DMLoadingManagerMain) {
        // A delay no test reaches, so no state hides by itself during a test.
        let manager = DMLoadingManagerMain(
            state: .none,
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudDismissal: rules)
        )
        trackForMemoryLeaks(manager, file: file, line: line)
        return (DefaultHUDViewModel(loadingManager: manager), manager)
    }
}
