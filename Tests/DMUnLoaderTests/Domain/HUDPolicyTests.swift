//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The decisions of the inner core, one phase at a time. The policies are plain values:
/// no actor, no scheduler, no view.
final class DismissPolicyTests: XCTestCase {

    func test_tapDismisses_noneSuccessAndFailure_isTrue() {
        let rules = DMHUDDismissalRules()
        for target in [HUDTapTarget.card, .backdrop] {
            XCTAssertTrue(
                DismissPolicy.tapDismisses(.none, on: target, rules: rules),
                "a tap without a state hides nothing (\(target))"
            )
            XCTAssertTrue(DismissPolicy.tapDismisses(.success, on: target, rules: rules), "a tap dismisses a success (\(target))")
            XCTAssertTrue(DismissPolicy.tapDismisses(.failure, on: target, rules: rules), "a tap dismisses a failure (\(target))")
        }
    }

    func test_tapDismisses_loading_isFalse() {
        for target in [HUDTapTarget.card, .backdrop] {
            XCTAssertFalse(
                DismissPolicy.tapDismisses(.loading, on: target, rules: DMHUDDismissalRules()),
                "a tap does not dismiss the loading phase (\(target))"
            )
        }
    }
}

final class HUDPhaseTests: XCTestCase {

    func test_showsHUD_none_isFalse() {
        XCTAssertFalse(HUDPhase.none.showsHUD, "no HUD without a state")
    }

    func test_showsHUD_loadingSuccessAndFailure_isTrue() {
        XCTAssertTrue(HUDPhase.loading.showsHUD, "the loading phase shows a HUD")
        XCTAssertTrue(HUDPhase.success.showsHUD, "a success shows a HUD")
        XCTAssertTrue(HUDPhase.failure.showsHUD, "a failure shows a HUD")
    }

    @MainActor
    func test_phase_ofEachLoadingState_isItsOwn() {
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()

        XCTAssertEqual(DMLoadableType.none.phase, .none, "no state, no phase")
        XCTAssertEqual(DMLoadableType.loading(provider: provider).phase, .loading, "loading maps to loading")
        XCTAssertEqual(DMLoadableType.success("done", provider: provider).phase, .success, "a success maps to success")
        XCTAssertEqual(
            DMLoadableType.failure(error: DMAppError.custom("failed"), provider: provider).phase,
            .failure,
            "a failure maps to failure"
        )
    }
}
