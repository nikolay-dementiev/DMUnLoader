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

    func test_loadingHUD_backdropClear_keepsTouchesFromContent() {
        assertLoadingHUDKeepsTouchesFromContent(launchArguments: Launch.swiftUI + ["--backdrop", "clear"])
    }

    func test_failureHUD_backdropClear_backdropTap_hidesTheHUDOnly() {
        assertBackdropTapHidesTheFailureOnly(backdropName: "clear")
    }

    func test_failureHUD_backdropDimOfClearColour_backdropTap_hidesTheHUDOnly() {
        assertBackdropTapHidesTheFailureOnly(backdropName: "dim-clear")
    }

    // MARK: - Card

    func test_successHUD_swiftUI_cardTap_hidesTheHUDOnly() {
        let app = launchExample(Launch.swiftUI)
        XCTAssertTrue(app.buttons[DemoIdentifier.showSuccess].waitForExistence(timeout: 30), "the demo screen is shown")
        app.buttons[DemoIdentifier.showSuccess].tap()
        let message = app.staticTexts["Loaded"]
        XCTAssertTrue(message.waitForExistence(timeout: 5), "the success HUD is shown")

        message.tap()

        XCTAssertTrue(message.waitForNonExistence(timeout: 5), "a tap on the card hides the success HUD")
        assertContentCountedNoTouch(in: app)
    }

    func test_failureHUD_swiftUI_cardTap_hidesTheHUDOnly() {
        let app = launchExample(Launch.swiftUI)
        XCTAssertTrue(app.buttons[DemoIdentifier.showFailure].waitForExistence(timeout: 30), "the demo screen is shown")
        app.buttons[DemoIdentifier.showFailure].tap()
        let message = app.staticTexts["The server did not answer."]
        XCTAssertTrue(message.waitForExistence(timeout: 5), "the failure HUD is shown")

        message.tap()

        XCTAssertTrue(
            app.buttons["Close"].waitForNonExistence(timeout: 5),
            "a tap on the card, off its buttons, hides the failure HUD"
        )
        assertContentCountedNoTouch(in: app)
    }

    func test_failureHUD_swiftUI_retry_keepsTheFailureShown() {
        let app = launchExample(Launch.swiftUI + ["--retry-counts-only"])
        XCTAssertTrue(app.buttons[DemoIdentifier.showFailure].waitForExistence(timeout: 30), "the demo screen is shown")
        app.buttons[DemoIdentifier.showFailure].tap()
        let retry = app.buttons["Retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 5), "the failure HUD is shown")

        retry.tap()

        XCTAssertTrue(
            label(of: app.staticTexts[DemoIdentifier.windowRetries], becomes: DemoText.retries(1), within: 5),
            "Retry runs the retry action"
        )
        XCTAssertFalse(
            app.buttons["Close"].waitForNonExistence(timeout: 1),
            "Retry leaves the failure on screen: a tap on a button of the card is not a tap on the card"
        )
        assertContentCountedNoTouch(in: app)
    }

    func test_failureHUD_swiftUI_retryTappedBesideItsTitle_runsTheRetryActionOnly() {
        let app = launchExample(Launch.swiftUI + ["--retry-counts-only"])
        XCTAssertTrue(app.buttons[DemoIdentifier.showFailure].waitForExistence(timeout: 30), "the demo screen is shown")
        app.buttons[DemoIdentifier.showFailure].tap()
        let retry = app.buttons["Retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 5), "the failure HUD is shown")

        // Inside the capsule of the button, away from its centred title.
        retry.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.5)).tap()

        XCTAssertTrue(
            label(of: app.staticTexts[DemoIdentifier.windowRetries], becomes: DemoText.retries(1), within: 5),
            "a tap inside the capsule of Retry, beside its title, runs the retry action"
        )
        XCTAssertFalse(
            app.buttons["Close"].waitForNonExistence(timeout: 1),
            "that tap is not a tap on the card, so the failure stays on screen"
        )
    }

    // MARK: - Dismissal rules

    func test_failureHUD_retryRuleCardOff_cardTapKeepsTheHUD() {
        let app = launchExample(Launch.swiftUI + ["--failure-with-retry-waits"])
        XCTAssertTrue(app.buttons[DemoIdentifier.showFailure].waitForExistence(timeout: 30), "the demo screen is shown")
        app.buttons[DemoIdentifier.showFailure].tap()
        let message = app.staticTexts["The server did not answer."]
        XCTAssertTrue(message.waitForExistence(timeout: 5), "the failure HUD is shown")

        message.tap()

        XCTAssertFalse(
            app.buttons["Close"].waitForNonExistence(timeout: 1),
            "a tap on the card keeps a failure with Retry whose rule says so"
        )
        assertContentCountedNoTouch(in: app)
    }

    func test_failureHUD_retryRuleCardOff_backdropTapHidesTheHUDOnly() {
        let app = launchExample(Launch.swiftUI + ["--failure-with-retry-waits"])
        let backdrop = backdropPoint(in: app)
        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5), "the failure HUD is shown")

        backdrop.tap()

        XCTAssertTrue(app.buttons["Close"].waitForNonExistence(timeout: 5), "a tap outside the card still hides the failure")
        assertContentCountedNoTouch(in: app)
    }

    // MARK: - Window level

    /// UIKit does not order windows within one level, so this pins what iOS 17.5, 18.6 and 26.5
    /// do today: a host window shown later at the normal level covers a HUD at that level.
    func test_failureHUD_coverShownLater_normalLevel_coverTakesTheTap() {
        let app = launchExample(Launch.swiftUI + ["--cover-after-hud"])
        let backdrop = backdropPoint(in: app)
        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons[DemoIdentifier.cover].waitForExistence(timeout: 5), "the host shows its cover after the HUD")

        backdrop.tap()

        XCTAssertTrue(
            label(of: app.buttons[DemoIdentifier.cover], becomes: DemoText.coverTaps(1), within: 5),
            "at the normal level the cover shown later takes the tap"
        )
    }

    func test_failureHUD_coverShownLater_aboveNormal_hudTakesTheTap() {
        let app = launchExample(Launch.swiftUI + ["--cover-after-hud", "--hud-above-normal"])
        let backdrop = backdropPoint(in: app)
        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons[DemoIdentifier.cover].waitForExistence(timeout: 5), "the host shows its cover after the HUD")

        backdrop.tap()

        XCTAssertTrue(
            app.buttons["Close"].waitForNonExistence(timeout: 5),
            "above the normal level the HUD takes the tap and hides"
        )
        XCTAssertEqual(app.buttons[DemoIdentifier.cover].label, DemoText.coverTaps(0), "the cover under the HUD counts no tap")
    }

    func test_idleOverlay_aboveNormal_letsTouchesReachContent() {
        assertIdleOverlayLetsTouchesReachContent(launchArguments: Launch.swiftUI + ["--hud-above-normal"])
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
            label(of: app.staticTexts[DemoIdentifier.windowRetries], becomes: DemoText.retries(1), within: 5),
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
            label(of: app.staticTexts[DemoIdentifier.windowContentTaps], becomes: DemoText.contentTaps(1), within: 5),
            "with the HUD hidden, a touch reaches the content again"
        )
    }

    // MARK: - Helpers

    /// With nothing drawn outside the card, a tap there still hides the failure and reaches
    /// nothing under the HUD.
    private func assertBackdropTapHidesTheFailureOnly(
        backdropName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let app = launchExample(Launch.swiftUI + ["--backdrop", backdropName])
        let backdrop = backdropPoint(in: app)
        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5), "the failure HUD is shown", file: file, line: line)

        backdrop.tap()

        XCTAssertTrue(
            app.buttons["Close"].waitForNonExistence(timeout: 5),
            "a tap outside the card hides the HUD with nothing drawn there",
            file: file,
            line: line
        )
        assertContentCountedNoTouch(in: app, file: file, line: line)
    }
}
