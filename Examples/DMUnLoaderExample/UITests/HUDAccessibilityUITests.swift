import XCTest

/// What assistive technology reaches while a HUD is shown: the HUD, and nothing of the app
/// under it.
@MainActor
final class HUDAccessibilityUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_hud_whileShown_hidesUnderlyingElements() {
        let app = launchExample(Launch.swiftUI)
        let content = app.buttons[DemoIdentifier.content]
        XCTAssertTrue(content.waitForExistence(timeout: 30), "the demo screen is shown")
        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5), "the failure HUD is shown")

        let contentReachable = content.exists
        let counterReachable = app.staticTexts[DemoIdentifier.contentTaps].exists
        app.buttons["Close"].tap()

        XCTAssertFalse(contentReachable, "the control under the HUD is out of reach while the HUD is shown")
        XCTAssertFalse(counterReachable, "the counters under the HUD are out of reach while the HUD is shown")
        XCTAssertTrue(content.waitForExistence(timeout: 5), "after Close the control is back")
    }
}
