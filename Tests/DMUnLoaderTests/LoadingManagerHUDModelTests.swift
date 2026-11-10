//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The projection of a loading manager onto the HUD model: it reads the manager whenever it is asked
/// and acts through it, and keeps no copy.
@MainActor
final class LoadingManagerHUDModelTests: XCTestCase {

    func test_phase_followsTheManager_afterTheModelWasMade() {
        let (sut, manager) = makeSUT()
        let phaseBefore = sut.phase

        manager.set(.loading(provider: Self.provider))
        let phaseWhileLoading = sut.phase
        manager.set(.none)

        XCTAssertEqual(phaseBefore, .none, "no phase while the manager has no state")
        XCTAssertEqual(phaseWhileLoading, .loading, "the loading phase once the manager shows it, without a new model")
        XCTAssertEqual(sut.phase, .none, "no phase again once the manager has none")
    }

    func test_phase_ofEachState_isThePhaseOfThatState() {
        let error = DMAppError.custom("failed")
        let states: [(state: DMLoadableType, phase: HUDPhase)] = [
            (.none, .none),
            (.loading(provider: Self.provider), .loading),
            (.success("Saved", provider: Self.provider), .success),
            (.failure(error: error, provider: Self.provider, onRetry: nil), .failure),
            (.failure(error: error, provider: Self.provider, onRetry: DMButtonAction {}), .failureWithRetry)
        ]
        for expected in states {
            let (sut, _) = makeSUT(state: expected.state)

            XCTAssertEqual(sut.phase, expected.phase, "the phase of \(expected.state)")
        }
    }

    func test_dismissalRules_areTheOnesOfTheManagersSettings() {
        let rules = DMHUDDismissalRules(success: DMHUDDismissal(backdropTapHides: false))
        let (sut, _) = makeSUT(settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudDismissal: rules))

        XCTAssertNotEqual(rules, DMHUDDismissalRules(), "the rules differ from the default ones, so the test can tell them apart")
        XCTAssertEqual(sut.dismissalRules, rules, "the model gives the rules of the manager's settings")
    }

    func test_hide_asksTheManagerToHideOnce() {
        let (sut, manager) = makeSUT(state: .success("Saved", provider: Self.provider))

        sut.hide()

        XCTAssertEqual(manager.hideCount, 1, "the model passes one hide on to the manager")
    }

    // MARK: - Helpers

    private static var provider: AnyDMLoadingViewProvider {
        DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
    }

    private func makeSUT(
        state: DMLoadableType = .none,
        settings: any DMLoadingManagerSettings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
    ) -> (sut: LoadingManagerHUDModel<HostLoadingManagerSpy>, manager: HostLoadingManagerSpy) {
        let manager = HostLoadingManagerSpy(loadableState: state, settings: settings)
        return (LoadingManagerHUDModel(manager), manager)
    }
}
