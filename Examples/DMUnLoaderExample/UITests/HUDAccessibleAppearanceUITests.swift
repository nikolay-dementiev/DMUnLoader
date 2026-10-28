import XCTest

/// The accessibility audit of the HUD in the accessible appearance, with every audit type, the
/// contrast and the clipped text included. `HUDAccessibilityUITests` audits the standard look
/// without those two: the accessible look is the one that has to pass them, at the default text
/// size and at the largest one.
@MainActor
final class HUDAccessibleAppearanceUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    // MARK: - Default text size

    func test_loadingHUD_defaultTextSize_accessibilityAudit_hasNoIssues() throws {
        try assertAuditHasNoIssues(at: .regular, after: DemoIdentifier.showLoading) { $0.staticTexts["Loading..."] }
    }

    func test_failureHUD_defaultTextSize_accessibilityAudit_hasNoIssues() throws {
        try assertAuditHasNoIssues(at: .regular, after: DemoIdentifier.showFailure) { $0.buttons["Retry"] }
    }

    func test_successHUD_defaultTextSize_accessibilityAudit_hasNoIssues() throws {
        try assertAuditHasNoIssues(at: .regular, after: DemoIdentifier.showSuccess) { $0.staticTexts["Loaded"] }
    }

    // MARK: - Largest text size

    func test_loadingHUD_largestTextSize_accessibilityAudit_hasNoIssues() throws {
        try assertAuditHasNoIssues(at: .largest, after: DemoIdentifier.showLoading) { $0.staticTexts["Loading..."] }
    }

    func test_failureHUD_largestTextSize_accessibilityAudit_hasNoIssues() throws {
        try assertAuditHasNoIssues(at: .largest, after: DemoIdentifier.showFailure) { $0.buttons["Retry"] }
    }

    func test_successHUD_largestTextSize_accessibilityAudit_hasNoIssues() throws {
        try assertAuditHasNoIssues(at: .largest, after: DemoIdentifier.showSuccess) { $0.staticTexts["Loaded"] }
    }

    // MARK: - The known finding of the loading HUD

    func test_knownLoadingLabelFinding_matchesOnlyTheLoadingTextWithThatDescription() {
        XCTAssertTrue(
            Self.isKnownLoadingLabelFinding(compactDescription: "Label not human-readable", label: "Loading..."),
            "that description on the label of the loading text is the known finding"
        )
        XCTAssertFalse(
            Self.isKnownLoadingLabelFinding(compactDescription: "Label not human-readable", label: "Loaded"),
            "that description on another label still fails the audit"
        )
        XCTAssertFalse(
            Self.isKnownLoadingLabelFinding(compactDescription: "Label not human-readable", label: nil),
            "that description on no element still fails the audit"
        )
        XCTAssertFalse(
            Self.isKnownLoadingLabelFinding(compactDescription: "Contrast failed", label: "Loading..."),
            "another finding on the label of the loading text still fails the audit"
        )
        XCTAssertFalse(
            Self.isKnownLoadingLabelFinding(compactDescription: "Text clipped", label: "Loading..."),
            "clipped text on the label of the loading text still fails the audit"
        )
    }

    // MARK: - Helpers

    /// The one finding of the audit that the loading HUD carries in every look: the default text
    /// "Loading..." is not a word to it. The label does not depend on the appearance, VoiceOver reads
    /// it as shown, and no documented criterion asks for another one; `HUDAccessibilityUITests`
    /// filters the same pair for the standard look. Nothing wider is filtered: another description,
    /// or the same description on another label, fails the audit.
    nonisolated static func isKnownLoadingLabelFinding(compactDescription: String, label: String?) -> Bool {
        compactDescription == "Label not human-readable" && label == "Loading..."
    }

    private enum TextSize: String {
        case regular = "UICTContentSizeCategoryL"
        case largest = "UICTContentSizeCategoryAccessibilityXXXL"
    }

    /// Shows the HUD that `button` asks for, in the accessible appearance, and audits it with every
    /// audit type once `shown` finds its element. The counters window is not launched: it lies
    /// above the HUD, so the audit would take its texts for part of the screen.
    private func assertAuditHasNoIssues(
        at size: TextSize,
        after button: String,
        shown: (XCUIApplication) -> XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let app = XCUIApplication()
        app.launchArguments = Launch.swiftUI + [
            "--appearance", "accessible",
            "--loading-duration", "600",
            "-UIPreferredContentSizeCategoryName", size.rawValue
        ]
        app.launch()
        let trigger = app.buttons[button]
        XCTAssertTrue(trigger.waitForExistence(timeout: Wait.launch), "the demo screen is shown", file: file, line: line)
        trigger.tap()
        XCTAssertTrue(shown(app).waitForExistence(timeout: Wait.screenChange), "the HUD is shown", file: file, line: line)

        try performAccessibilityAuditRetryingTimeouts {
            try app.performAccessibilityAudit(for: .all) { issue in
                Self.isKnownLoadingLabelFinding(compactDescription: issue.compactDescription, label: issue.element?.label)
            }
        }
    }
}
