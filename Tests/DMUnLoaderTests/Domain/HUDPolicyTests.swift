//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The decisions of the inner core, one phase at a time. The policies are plain values:
/// no actor, no scheduler, no view.
final class AutoHidePolicyTests: XCTestCase {

    func test_hidesAfterDelay_successAndFailure_isTrue() {
        XCTAssertTrue(AutoHidePolicy.hidesAfterDelay(.success), "a success hides after the delay")
        XCTAssertTrue(AutoHidePolicy.hidesAfterDelay(.failure), "a failure hides after the delay")
    }

    func test_hidesAfterDelay_noneAndLoading_isFalse() {
        XCTAssertFalse(AutoHidePolicy.hidesAfterDelay(.none), "nothing to hide without a state")
        XCTAssertFalse(AutoHidePolicy.hidesAfterDelay(.loading), "the loading phase waits for its result")
    }
}

final class DismissPolicyTests: XCTestCase {

    func test_tapDismisses_noneSuccessAndFailure_isTrue() {
        XCTAssertTrue(DismissPolicy.tapDismisses(.none), "a tap without a state hides nothing, harmlessly")
        XCTAssertTrue(DismissPolicy.tapDismisses(.success), "a tap dismisses a success")
        XCTAssertTrue(DismissPolicy.tapDismisses(.failure), "a tap dismisses a failure")
    }

    func test_tapDismisses_loading_isFalse() {
        XCTAssertFalse(DismissPolicy.tapDismisses(.loading), "a tap does not dismiss the loading phase")
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
