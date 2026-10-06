import XCTest

/// The launch arguments of the example's integration modes. Each UI test class launches
/// the app in the modes of one scene-delegate class only: `Scripts/test-example.sh` runs
/// the classes group by group and uninstalls the app between groups.
enum Launch {
    /// A host-owned DMLoadingManagerMain whose success and failure outlast the test.
    static let swiftUI = ["--auto-hide", "600"]
    /// The same, with no app delegate of the library: the app gives its manager to
    /// `DMRootLoadingView(manager:content:)`.
    static let injected = ["--injected", "--auto-hide", "600"]
    /// A manager written by the host, without a timer.
    static let customManager = ["--custom-manager"]
    static let uiKitCustomManager = ["--uikit", "--custom-manager"]
}

/// How long the UI tests wait for the app.
enum Wait {
    /// The launched app shows its demo screen.
    static let launch: TimeInterval = 30
    /// The screen changes after a tap: a HUD appears or goes, a counter changes. A wait returns
    /// as soon as its condition holds, so the budget costs a passing run nothing. It is not 5 s:
    /// on a hosted runner one launch took 12.7 s to set up its automation session and one
    /// existence check took 3.3 s, and a wait of 5 s ran out while the app was still answering.
    static let screenChange: TimeInterval = 15
    /// A touch has no effect. Such a wait has to run out, so its length is what the check costs.
    static let noEffect: TimeInterval = 1
    /// Two touches have no effect.
    static let noEffectOfTwoTouches: TimeInterval = 2
}

/// Launching the example, and the touches and checks the UI test classes share.
@MainActor
extension XCTestCase {
    func launchExample(_ arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        // The simulated work outlasts the test, so the loading HUD cannot end by itself. The
        // counters are read from the window above the HUD, which the HUD leaves reachable.
        app.launchArguments = arguments + ["--loading-duration", "600", "--counters-window"]
        app.launch()
        return app
    }

    /// Two screen points inside the content control: the centre of the screen, which the
    /// HUD card covers because the card is centred, and a point near the bottom of the
    /// control, where only the backdrop is.
    ///
    /// They are taken from the frame once it has settled on one that covers the centre, before
    /// any HUD is shown, and resolved against the app, so tapping them never depends on finding
    /// the control under a HUD. A frame read during the launch animation misses the control.
    func contentTouchPoints(
        in app: XCUIApplication,
        content: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [XCUICoordinate] {
        let centre = centreOfScreen(of: app)
        guard let frame = settledContentFrame(of: content, covering: centre, file: file, line: line) else {
            return []
        }
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
        XCTAssertTrue(content.waitForExistence(timeout: Wait.launch), "the demo screen is shown", file: file, line: line)

        contentTouchPoints(in: app, content: content, file: file, line: line).forEach { $0.tap() }

        XCTAssertTrue(
            label(
                of: app.staticTexts[DemoIdentifier.windowContentTaps],
                becomes: DemoText.contentTaps(2),
                within: Wait.screenChange
            ),
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
        XCTAssertTrue(content.waitForExistence(timeout: Wait.launch), "the demo screen is shown", file: file, line: line)
        let touchPoints = contentTouchPoints(in: app, content: content, file: file, line: line)

        app.buttons[DemoIdentifier.showLoading].tap()
        let loadingText = app.staticTexts["Loading..."]
        XCTAssertTrue(
            loadingText.waitForExistence(timeout: Wait.screenChange),
            "the loading HUD is shown",
            file: file,
            line: line
        )

        touchPoints.forEach { $0.tap() }

        let counter = app.staticTexts[DemoIdentifier.windowContentTaps]
        XCTAssertFalse(
            label(of: counter, leaves: DemoText.contentTaps(0), within: Wait.noEffectOfTwoTouches),
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
            app.buttons[DemoIdentifier.showFailure].waitForExistence(timeout: Wait.launch),
            "the demo screen is shown",
            file: file,
            line: line
        )
        app.buttons[DemoIdentifier.showFailure].tap()
        let retry = app.buttons["Retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: Wait.screenChange), "the failure HUD is shown", file: file, line: line)

        retry.tap()

        XCTAssertTrue(
            label(of: app.staticTexts[DemoIdentifier.windowRetries], becomes: DemoText.retries(1), within: Wait.screenChange),
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
            app.buttons[DemoIdentifier.showFailure].waitForExistence(timeout: Wait.launch),
            "the demo screen is shown",
            file: file,
            line: line
        )
        app.buttons[DemoIdentifier.showFailure].tap()
        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: Wait.screenChange), "the failure HUD is shown", file: file, line: line)

        close.tap()

        XCTAssertTrue(
            close.waitForNonExistence(timeout: Wait.screenChange),
            "Close hides the failure HUD",
            file: file,
            line: line
        )
        XCTAssertEqual(
            app.staticTexts[DemoIdentifier.windowRetries].label,
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
        XCTAssertTrue(content.waitForExistence(timeout: Wait.launch), "the demo screen is shown")
        let origin = app.coordinate(withNormalizedOffset: .zero)
        guard let frame = settledContentFrame(of: content, covering: centreOfScreen(of: app)) else {
            return origin
        }
        return origin.withOffset(CGVector(dx: frame.midX, dy: frame.maxY - 20))
    }

    /// The centre of the screen, which the HUD card covers.
    func centreOfScreen(of app: XCUIApplication) -> CGPoint {
        CGPoint(x: app.frame.midX, y: app.frame.midY)
    }

    /// The frame of the content control once it has settled on a frame that covers `centre`.
    /// When none settles within `Wait.screenChange`, the test fails and names the frames read.
    func settledContentFrame(
        of content: XCUIElement,
        covering centre: CGPoint,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> CGRect? {
        switch settledFrame(from: .of(content), containing: centre, within: Wait.screenChange) {
        case let .settled(frame):
            return frame
        case let .unsettled(reads):
            XCTFail(
                "the content control settles on no frame that covers the centre of the screen; frames read: \(reads)",
                file: file,
                line: line
            )
            return nil
        }
    }

    func assertContentCountedNoTouch(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let counter = app.staticTexts[DemoIdentifier.windowContentTaps]
        XCTAssertFalse(
            label(of: counter, leaves: DemoText.contentTaps(0), within: Wait.noEffect),
            "a touch on the HUD must not also reach the content under it",
            file: file,
            line: line
        )
    }
}
