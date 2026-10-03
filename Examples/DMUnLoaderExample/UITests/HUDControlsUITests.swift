import XCTest

/// Real touches on the controls of a shown HUD: Retry, Close and the backdrop.
///
/// Every launch keeps a success or a failure on screen far longer than a test runs, so a
/// HUD that hides by its timer cannot pass for a working Close or a working backdrop tap.
/// After each dismissing touch the control under the HUD must still count no touch.
@MainActor
final class HUDControlsUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    // MARK: - Retry

    func test_failureHUD_swiftUI_retry_runsTheRetryActionOnly() {
        assertRetryRunsTheRetryActionOnly(launchArguments: Launch.swiftUI)
    }

    func test_failureHUD_customManager_retry_runsTheRetryActionOnly() {
        assertRetryRunsTheRetryActionOnly(launchArguments: Launch.customManager)
    }

    // MARK: - Close

    func test_failureHUD_swiftUI_close_hidesTheHUDOnly() {
        assertCloseHidesTheHUDOnly(launchArguments: Launch.swiftUI)
    }

    func test_failureHUD_customManager_close_hidesTheHUDOnly() {
        assertCloseHidesTheHUDOnly(launchArguments: Launch.customManager)
    }

    // MARK: - Backdrop

    func test_failureHUD_swiftUI_backdropTap_hidesTheHUDOnly() {
        let app = launchExample(Launch.swiftUI)
        let backdrop = backdropPoint(in: app)
        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5), "the failure HUD is shown")

        backdrop.tap()

        XCTAssertTrue(app.buttons["Close"].waitForNonExistence(timeout: 5), "a tap on the backdrop hides the failure HUD")
        assertContentCountedNoTouch(in: app)
    }

    func test_successHUD_swiftUI_backdropTap_hidesTheHUDOnly() {
        let app = launchExample(Launch.swiftUI)
        let backdrop = backdropPoint(in: app)
        app.buttons[DemoIdentifier.showSuccess].tap()
        let successText = app.staticTexts["Loaded"]
        XCTAssertTrue(successText.waitForExistence(timeout: 5), "the success HUD is shown")

        backdrop.tap()

        XCTAssertTrue(successText.waitForNonExistence(timeout: 5), "a tap on the backdrop hides the success HUD")
        assertContentCountedNoTouch(in: app)
    }

    // MARK: - Presentation order

    func test_failureHUD_swiftUI_secondPresentation_retryStillWorks() {
        let app = launchExample(Launch.swiftUI)
        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5), "the first failure HUD is shown")
        app.buttons["Close"].tap()
        XCTAssertTrue(app.buttons["Close"].waitForNonExistence(timeout: 5), "Close hides the first failure HUD")

        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Retry"].waitForExistence(timeout: 5), "the second failure HUD is shown")
        app.buttons["Retry"].tap()

        XCTAssertTrue(
            label(of: app.staticTexts[DemoIdentifier.retries], becomes: DemoText.retries(1), within: 5),
            "Retry of the second presentation runs the retry action"
        )
        assertContentCountedNoTouch(in: app)
    }

    func test_initialFailureState_swiftUI_close_hidesTheHUDThenContentGetsTouches() {
        // The manager holds a failure before the HUD window is created and shown.
        let app = launchExample(Launch.swiftUI + ["--initial-failure"])
        let content = app.buttons[DemoIdentifier.content]
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 30), "the HUD of the initial failure is shown")

        app.buttons["Close"].tap()

        XCTAssertTrue(app.buttons["Close"].waitForNonExistence(timeout: 5), "Close hides the HUD of the initial failure")
        assertContentCountedNoTouch(in: app)
        content.tap()
        XCTAssertTrue(
            label(of: app.staticTexts[DemoIdentifier.contentTaps], becomes: DemoText.contentTaps(1), within: 5),
            "with the HUD hidden, a touch reaches the content again"
        )
    }

}
