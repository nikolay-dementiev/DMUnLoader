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
        let sut = DefaultHUDViewModel(model: LoadingManagerHUDModel(manager))

        sut.backdropTapped()

        XCTAssertTrue(manager.loadableState.showsHUD, "a manager of the host's own keeps the success when its settings say so")
    }

    func test_backdropTapped_aManagerWhoseHideKeepsItsState_reportsThatTheHUDStayed() {
        let manager = HostLoadingManagerSpy(
            loadableState: .success("done", provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider())
        )
        let sut = DefaultHUDViewModel(model: LoadingManagerHUDModel(manager))

        let hid = sut.backdropTapped()

        XCTAssertEqual(manager.hideCount, 1, "the tap asks the manager to hide the success")
        XCTAssertFalse(hid, "the success is still shown after the call, so the tap reports that the HUD stayed")
    }

    func test_cardAndBackdropTap_withNoState_askTheManagerForNothing() {
        let manager = HostLoadingManagerSpy()
        let sut = DefaultHUDViewModel(model: LoadingManagerHUDModel(manager))

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

    func test_cardAndBackdropTap_onARefusingManager_askItToHideExactlyOnce() {
        for show in Show.allCases {
            for tap in Tap.allCases {
                let manager = HostLoadingManagerSpy(loadableState: show.loadableState)
                let sut = DefaultHUDViewModel(model: LoadingManagerHUDModel(manager))

                tap.send(to: sut)

                XCTAssertEqual(manager.hideCount, 1, "a tap on the \(tap) asks the manager once to hide \(show)")
            }
        }
    }

    func test_closeTapped_whenTheRulesRefuseEveryTap_stillAsksTheManagerToHideOnce() {
        let refusing = DMHUDDismissal(cardTapHides: false, backdropTapHides: false)
        let rules = DMHUDDismissalRules(success: refusing, failureWithoutRetry: refusing, failureWithRetry: refusing)
        let manager = HostLoadingManagerSpy(
            loadableState: Show.failureWithRetry.loadableState,
            settings: DMLoadingManagerDefaultSettings(hudDismissal: rules)
        )
        let sut = DefaultHUDViewModel(model: LoadingManagerHUDModel(manager))

        sut.cardTapped()
        sut.backdropTapped()
        let hidesAskedByTaps = manager.hideCount
        sut.closeTapped()

        XCTAssertEqual(hidesAskedByTaps, 0, "with every rule off, a tap on the card or outside it asks for no hide")
        XCTAssertEqual(manager.hideCount, 1, "Close is no tap on the card: it asks for the hide once, whatever the rules say")
    }

    // MARK: - Helpers

    private enum Tap: CaseIterable, CustomStringConvertible {
        case card
        case backdrop

        var description: String {
            self == .card ? "card" : "backdrop"
        }

        @MainActor
        func send(to viewModel: DefaultHUDViewModel) {
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

        /// The state itself, for a manager that is made already showing it.
        @MainActor
        var loadableState: DMLoadableType {
            let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
            switch self {
            case .success:
                return .success("done", provider: provider)
            case .failureWithoutRetry:
                return .failure(error: DMAppError.custom("failed"), provider: provider)
            case .failureWithRetry:
                return .failure(error: DMAppError.custom("failed"), provider: provider, onRetry: DMButtonAction {})
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
    ) -> (sut: DefaultHUDViewModel, manager: DMLoadingManagerMain) {
        // A delay no test reaches, so no state hides by itself during a test.
        let manager = DMLoadingManagerMain(
            state: .none,
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudDismissal: rules)
        )
        trackForMemoryLeaks(manager, file: file, line: line)
        return (DefaultHUDViewModel(model: LoadingManagerHUDModel(manager)), manager)
    }
}
