//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// Whether a state shows a HUD decides whether the HUD window takes the touches.
@MainActor
final class DMLoadableTypeShowsHUDTests: XCTestCase {

    func test_showsHUD_withNoState_isFalse() {
        XCTAssertFalse(DMLoadableType.none.showsHUD, "no HUD without a state, so touches reach the app")
    }

    func test_showsHUD_forLoadingSuccessAndFailure_isTrue() {
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()

        XCTAssertTrue(DMLoadableType.loading(provider: provider).showsHUD, "the loading state shows a HUD")
        XCTAssertTrue(DMLoadableType.success("done", provider: provider).showsHUD, "a success shows a HUD")
        XCTAssertTrue(
            DMLoadableType.failure(error: DMAppError.custom("failed"), provider: provider).showsHUD,
            "a failure shows a HUD"
        )
    }
}
