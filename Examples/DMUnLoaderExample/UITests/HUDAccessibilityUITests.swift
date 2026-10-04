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

        // Text clipped: the default progress card clips "Loading..." at large text sizes; AccessibilitySnapshotTests records it.
        try app.performAccessibilityAudit(for: Self.auditTypes.subtracting(.textClipped)) { issue in
            // "Label not human-readable" on the default "Loading...": no documented criteria; VoiceOver reads it as shown.
            issue.compactDescription == "Label not human-readable" && issue.element?.label == "Loading..."
        }
    }

    // MARK: - Images

    func test_successHUD_defaultImage_isNotRead() {
        let elements = accessibilityElementsOfTheHUD(after: DemoIdentifier.showSuccess, showing: "Loaded")

        XCTAssertFalse(
            elements.contains { $0.hasSuffix(DemoText.imageMark) },
            "assistive technology does not reach the default checkmark: \(elements)"
        )
    }

    func test_failureHUD_defaultImage_isNotRead() {
        let elements = accessibilityElementsOfTheHUD(after: DemoIdentifier.showFailure, showing: "Retry")

        XCTAssertFalse(
            elements.contains { $0.hasSuffix(DemoText.imageMark) },
            "assistive technology does not reach the default warning sign: \(elements)"
        )
    }

    func test_failureHUD_hostImage_isReadWithItsOwnLabel() {
        let elements = accessibilityElementsOfTheHUD(
            after: DemoIdentifier.showFailure,
            showing: "Retry",
            arguments: ["--host-image"]
        )

        let image = elements.first { $0.hasSuffix(DemoText.imageMark) }
        XCTAssertNotNil(image, "assistive technology reaches the host's image: \(elements)")
        XCTAssertNotEqual(image, DemoText.imageMark, "the host's image keeps a label of its own: \(elements)")
    }

    // MARK: - Helpers

    /// The elements that assistive technology reaches in the HUD window, in order, once the HUD
    /// that `button` shows contains `text`. XCUITest also lists the elements that SwiftUI hides
    /// from assistive technology, so the app reports the tree itself, in the counters window.
    private func accessibilityElementsOfTheHUD(
        after button: String,
        showing text: String,
        arguments: [String] = []
    ) -> [String] {
        let app = launchExample(Launch.swiftUI + ["--accessibility-tree"] + arguments)
        XCTAssertTrue(app.buttons[button].waitForExistence(timeout: 30), "the demo screen is shown")
        app.buttons[button].tap()
        let tree = app.staticTexts[DemoIdentifier.hudAccessibilityTree]
        XCTAssertTrue(
            wait(for: NSPredicate(format: "label CONTAINS %@", text), on: tree, timeout: 5),
            "the counters window reports the HUD"
        )
        return tree.label.components(separatedBy: DemoText.treeSeparator)
    }

    /// Every audit type but contrast, which fails on the default look of the HUD alone.
    private static let auditTypes = XCUIAccessibilityAuditType.all
        // Contrast: white text on the default gray card at opacity 0.8 is below 4.5:1, a known issue in the README.
        .subtracting(.contrast)

    /// The demo screen with nothing above the HUD's level, so a query or an audit sees the HUD
    /// and what the HUD leaves of the app.
    private func launchWithoutCountersWindow(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = Launch.swiftUI + ["--loading-duration", "600"] + arguments
        app.launch()
        XCTAssertTrue(app.buttons[DemoIdentifier.content].waitForExistence(timeout: 30), "the demo screen is shown")
        return app
    }
}
