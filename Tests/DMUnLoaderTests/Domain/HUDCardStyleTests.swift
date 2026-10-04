//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The gray of the card of a HUD, decided without rendering.
final class HUDCardStyleTests: XCTestCase {

    func test_backgroundOpacity_reduceTransparency_isOpaqueWhetherShownOrNot() {
        XCTAssertEqual(
            HUDCardStyle.backgroundOpacity(isShown: true, reducesTransparency: true),
            1,
            "a shown card is opaque under Reduce Transparency"
        )
        XCTAssertEqual(
            HUDCardStyle.backgroundOpacity(isShown: false, reducesTransparency: true),
            1,
            "a card fading in is opaque under Reduce Transparency"
        )
    }

    func test_backgroundOpacity_shown_isTheShownGray() {
        XCTAssertEqual(
            HUDCardStyle.backgroundOpacity(isShown: true, reducesTransparency: false),
            0.8,
            "a shown card is gray at opacity 0.8"
        )
    }

    func test_backgroundOpacity_fadingIn_isTheFadedGray() {
        XCTAssertEqual(
            HUDCardStyle.backgroundOpacity(isShown: false, reducesTransparency: false),
            0.1,
            "a card fading in is gray at opacity 0.1"
        )
    }
}
