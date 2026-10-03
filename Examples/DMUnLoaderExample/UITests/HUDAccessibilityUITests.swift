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

    // MARK: - Audits

    func test_failureHUD_accessibilityAudit_hasNoIssues() throws {
        let app = launchWithoutCountersWindow()
        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Retry"].waitForExistence(timeout: 5), "the failure HUD is shown")

        try app.performAccessibilityAudit(for: Self.auditTypes)
    }

    func test_loadingHUD_accessibilityAudit_hasNoIssuesButTheLoadingText() throws {
        let app = launchWithoutCountersWindow()
        app.buttons[DemoIdentifier.showLoading].tap()
        XCTAssertTrue(app.staticTexts["Loading..."].waitForExistence(timeout: 5), "the loading HUD is shown")

        try app.performAccessibilityAudit(for: Self.auditTypes) { issue in
            // "Label not human-readable" on the default "Loading...": no documented criteria; VoiceOver reads it as shown.
            issue.compactDescription == "Label not human-readable" && issue.element?.label == "Loading..."
        }
    }

    // MARK: - Helpers

    /// Every audit type but two, each failing on the default look of the HUD alone.
    private static let auditTypes = XCUIAccessibilityAuditType.all
        // Contrast: white text on the default gray card at opacity 0.8 fails it; 1.1.0 keeps the released colours.
        .subtracting(.contrast)
        // Text clipped: the default progress card clips "Loading..." at large text sizes; AccessibilitySnapshotTests records it.
        .subtracting(.textClipped)

    /// The demo screen with nothing above the HUD's level, so an audit sees the HUD and what
    /// the HUD leaves of the app.
    private func launchWithoutCountersWindow() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = Launch.swiftUI + ["--loading-duration", "600"]
        app.launch()
        XCTAssertTrue(app.buttons[DemoIdentifier.content].waitForExistence(timeout: 30), "the demo screen is shown")
        return app
    }
}
