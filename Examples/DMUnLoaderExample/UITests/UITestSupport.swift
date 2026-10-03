import XCTest

/// The launch arguments of the example's integration modes. Each UI test class launches
/// the app in the modes of one scene-delegate class only: `Scripts/test-example.sh` runs
/// the classes group by group and uninstalls the app between groups.
enum Launch {
    /// A host-owned DMLoadingManagerMain whose success and failure outlast the test.
    static let swiftUI = ["--auto-hide", "600"]
    /// A manager written by the host, without a timer.
    static let customManager = ["--custom-manager"]
    static let uiKitCustomManager = ["--uikit", "--custom-manager"]
}

/// Launching the example, and the touches and checks the UI test classes share.
@MainActor
extension XCTestCase {
    func launchExample(_ arguments: [String]) -> XCUIApplication {
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
    func contentTouchPoints(
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

    func label(of element: XCUIElement, becomes expected: String, within timeout: TimeInterval) -> Bool {
        wait(for: NSPredicate(format: "label == %@", expected), on: element, timeout: timeout)
    }

    func label(of element: XCUIElement, leaves initial: String, within timeout: TimeInterval) -> Bool {
        wait(for: NSPredicate(format: "label != %@", initial), on: element, timeout: timeout)
    }

    func wait(for predicate: NSPredicate, on element: XCUIElement, timeout: TimeInterval) -> Bool {
        let matches = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [matches], timeout: timeout) == .completed
    }

    func assertIdleOverlayLetsTouchesReachContent(
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

    func assertLoadingHUDKeepsTouchesFromContent(
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

    func assertRetryRunsTheRetryActionOnly(
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

    func assertCloseHidesTheHUDOnly(
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
    func backdropPoint(in app: XCUIApplication) -> XCUICoordinate {
        let content = app.buttons[DemoIdentifier.content]
        XCTAssertTrue(content.waitForExistence(timeout: 30), "the demo screen is shown")
        let frame = content.frame
        return app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: frame.midX, dy: frame.maxY - 20))
    }

    func assertContentCountedNoTouch(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let counter = app.staticTexts[DemoIdentifier.contentTaps]
        XCTAssertFalse(
            label(of: counter, leaves: DemoText.contentTaps(0), within: 1),
            "a touch on the HUD must not also reach the content under it",
            file: file,
            line: line
        )
    }
}
