import XCTest

/// Real touches against the example app, on every way of integrating the library.
///
/// The HUD lives in its own window above the app. These tests pin what that window does
/// with touches: it lets them through while nothing is shown, and it keeps them away from
/// the content while the loading HUD is shown.
@MainActor
final class HUDTouchRoutingUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    // MARK: - No HUD: touches reach the content

    func test_idleOverlay_swiftUI_letsTouchesReachContent() {
        assertIdleOverlayLetsTouchesReachContent(launchArguments: [])
    }

    func test_idleOverlay_uiKit_letsTouchesReachContent() {
        assertIdleOverlayLetsTouchesReachContent(launchArguments: ["--uikit"])
    }

    func test_idleOverlay_customManager_letsTouchesReachContent() {
        assertIdleOverlayLetsTouchesReachContent(launchArguments: ["--custom-manager"])
    }

    // MARK: - Loading HUD: touches do not reach the content

    func test_loadingHUD_swiftUI_keepsTouchesFromContent() {
        assertLoadingHUDKeepsTouchesFromContent(launchArguments: [])
    }

    func test_loadingHUD_uiKit_keepsTouchesFromContent() {
        assertLoadingHUDKeepsTouchesFromContent(launchArguments: ["--uikit"])
    }

    func test_loadingHUD_customManager_keepsTouchesFromContent() {
        assertLoadingHUDKeepsTouchesFromContent(launchArguments: ["--custom-manager"])
    }

    // MARK: - Helpers

    private func launchExample(_ arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        // The simulated work outlasts the test, so the loading HUD cannot end by itself.
        app.launchArguments = arguments + ["--loading-duration", "600"]
        app.launch()
        return app
    }

    /// Two screen points inside the content control: the centre of the screen, which the
    /// HUD card covers because the card is centred, and a point near the bottom of the
    /// control, where only the backdrop is.
    ///
    /// They are taken from the frames before any HUD is shown and resolved against the app,
    /// so tapping them never depends on finding the control under a HUD.
    private func contentTouchPoints(
        in app: XCUIApplication,
        content: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [XCUICoordinate] {
        let frame = content.frame
        let screen = app.frame
        let centre = CGPoint(x: screen.midX, y: screen.midY)
        XCTAssertTrue(frame.contains(centre), "the content control covers the centre of the screen", file: file, line: line)
        let origin = app.coordinate(withNormalizedOffset: .zero)
        return [
            origin.withOffset(CGVector(dx: centre.x, dy: centre.y)),
            origin.withOffset(CGVector(dx: frame.midX, dy: frame.maxY - 20))
        ]
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

    private func assertIdleOverlayLetsTouchesReachContent(
        launchArguments: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let app = launchExample(launchArguments)
        let content = app.buttons[DemoIdentifier.content]
        XCTAssertTrue(content.waitForExistence(timeout: 30), "the demo screen is shown", file: file, line: line)

        contentTouchPoints(in: app, content: content, file: file, line: line).forEach { $0.tap() }

        XCTAssertTrue(
            label(of: app.staticTexts[DemoIdentifier.contentTaps], becomes: DemoText.contentTaps(2), within: 5),
            "with no HUD shown, both touches must reach the content under the overlay window",
            file: file,
            line: line
        )
    }

    private func assertLoadingHUDKeepsTouchesFromContent(
        launchArguments: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let app = launchExample(launchArguments)
        let content = app.buttons[DemoIdentifier.content]
        XCTAssertTrue(content.waitForExistence(timeout: 30), "the demo screen is shown", file: file, line: line)
        let touchPoints = contentTouchPoints(in: app, content: content, file: file, line: line)

        app.buttons[DemoIdentifier.showLoading].tap()
        let loadingText = app.staticTexts["Loading..."]
        XCTAssertTrue(loadingText.waitForExistence(timeout: 5), "the loading HUD is shown", file: file, line: line)

        touchPoints.forEach { $0.tap() }

        let counter = app.staticTexts[DemoIdentifier.contentTaps]
        XCTAssertFalse(
            label(of: counter, leaves: DemoText.contentTaps(0), within: 2),
            "a touch under the HUD card or on the backdrop must not reach the content",
            file: file,
            line: line
        )
        XCTAssertEqual(
            counter.label,
            DemoText.contentTaps(0),
            "the content must have counted no touch while the loading HUD was shown",
            file: file,
            line: line
        )
        XCTAssertTrue(loadingText.exists, "the loading HUD stays while the work runs", file: file, line: line)
    }
}
