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

    func test_failureHUD_uiKitCustomManager_retry_runsTheRetryActionOnly() {
        assertRetryRunsTheRetryActionOnly(launchArguments: Launch.uiKitCustomManager)
    }

    // MARK: - Close

    func test_failureHUD_swiftUI_close_hidesTheHUDOnly() {
        assertCloseHidesTheHUDOnly(launchArguments: Launch.swiftUI)
    }

    func test_failureHUD_customManager_close_hidesTheHUDOnly() {
        assertCloseHidesTheHUDOnly(launchArguments: Launch.customManager)
    }

    func test_failureHUD_uiKitCustomManager_close_hidesTheHUDOnly() {
        assertCloseHidesTheHUDOnly(launchArguments: Launch.uiKitCustomManager)
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

    // MARK: - Helpers

    private enum Launch {
        /// A host-owned DMLoadingManagerMain whose success and failure outlast the test.
        static let swiftUI = ["--auto-hide", "600"]
        /// A manager written by the host, without a timer.
        static let customManager = ["--custom-manager"]
        static let uiKitCustomManager = ["--uikit", "--custom-manager"]
    }

    private func launchExample(_ arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        // The simulated work after Retry outlasts the test, so its loading HUD stays.
        app.launchArguments = arguments + ["--loading-duration", "600"]
        app.launch()
        return app
    }

    private func assertRetryRunsTheRetryActionOnly(
        launchArguments: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let app = launchExample(launchArguments)
        XCTAssertTrue(
            app.buttons[DemoIdentifier.showFailure].waitForExistence(timeout: 30),
            "the demo screen is shown",
            file: file,
            line: line
        )
        app.buttons[DemoIdentifier.showFailure].tap()
        let retry = app.buttons["Retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 5), "the failure HUD is shown", file: file, line: line)

        retry.tap()

        XCTAssertTrue(
            label(of: app.staticTexts[DemoIdentifier.retries], becomes: DemoText.retries(1), within: 5),
            "Retry runs the retry action",
            file: file,
            line: line
        )
        assertContentCountedNoTouch(in: app, file: file, line: line)
    }

    private func assertCloseHidesTheHUDOnly(
        launchArguments: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let app = launchExample(launchArguments)
        XCTAssertTrue(
            app.buttons[DemoIdentifier.showFailure].waitForExistence(timeout: 30),
            "the demo screen is shown",
            file: file,
            line: line
        )
        app.buttons[DemoIdentifier.showFailure].tap()
        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: 5), "the failure HUD is shown", file: file, line: line)

        close.tap()

        XCTAssertTrue(close.waitForNonExistence(timeout: 5), "Close hides the failure HUD", file: file, line: line)
        XCTAssertEqual(
            app.staticTexts[DemoIdentifier.retries].label,
            DemoText.retries(0),
            "Close does not run the retry action",
            file: file,
            line: line
        )
        assertContentCountedNoTouch(in: app, file: file, line: line)
    }

    /// A point inside the content control, below the HUD card: only the backdrop covers it.
    private func backdropPoint(in app: XCUIApplication) -> XCUICoordinate {
        let content = app.buttons[DemoIdentifier.content]
        XCTAssertTrue(content.waitForExistence(timeout: 30), "the demo screen is shown")
        let frame = content.frame
        return app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: frame.midX, dy: frame.maxY - 20))
    }

    private func assertContentCountedNoTouch(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let counter = app.staticTexts[DemoIdentifier.contentTaps]
        XCTAssertFalse(
            label(of: counter, leaves: DemoText.contentTaps(0), within: 1),
            "a touch on the HUD must not also reach the content under it",
            file: file,
            line: line
        )
    }

    private func label(of element: XCUIElement, becomes expected: String, within timeout: TimeInterval) -> Bool {
        wait(for: NSPredicate(format: "label == %@", expected), on: element, timeout: timeout)
    }

    private func label(of element: XCUIElement, leaves initial: String, within timeout: TimeInterval) -> Bool {
        wait(for: NSPredicate(format: "label != %@", initial), on: element, timeout: timeout)
    }

    private func wait(for predicate: NSPredicate, on element: XCUIElement, timeout: TimeInterval) -> Bool {
        let matches = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [matches], timeout: timeout) == .completed
    }
}
