import XCTest

/// The texts of the HUD in other languages: a pseudolanguage that doubles every text looked
/// up in a table, a preferred language the library has no texts for, and a right-to-left
/// language. Each launch sets the language with the arguments Apple documents for testing an
/// internationalized app.
@MainActor
final class HUDLanguageUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_failureHUD_doubleLengthPseudolanguage_looksUpTheDefaults() {
        let doubled = ["-NSDoubleLocalizedStrings", "YES"]
        let loadingApp = launchExample(Launch.swiftUI + doubled)
        loadingApp.buttons[DemoIdentifier.showLoading].tap()
        let loading = text(beginningWith: "Loading...", in: loadingApp)
        XCTAssertTrue(loading.waitForExistence(timeout: Wait.screenChange), "the loading HUD shows its text")
        let loadingLabel = loading.label

        let app = launchExample(Launch.swiftUI + doubled)
        app.buttons[DemoIdentifier.showFailure].tap()
        let title = text(beginningWith: "An error has occurred!", in: app)
        XCTAssertTrue(title.waitForExistence(timeout: Wait.screenChange), "the failure HUD shows its title")

        let close = button(beginningWith: "Close", in: app).label
        let retry = button(beginningWith: "Retry", in: app).label
        // The run's log keeps what the pseudolanguage made of each text.
        XCTContext.runActivity(named: "Doubled: \(loadingLabel) | \(title.label) | \(close) | \(retry)") { _ in }

        XCTAssertGreaterThan(loadingLabel.count, "Loading...".count, "the loading text is looked up: \(loadingLabel)")
        XCTAssertGreaterThan(title.label.count, "An error has occurred!".count, "the title is looked up: \(title.label)")
        XCTAssertGreaterThan(close.count, "Close".count, "the Close text is looked up: \(close)")
        XCTAssertGreaterThan(retry.count, "Retry".count, "the Retry text is looked up: \(retry)")
    }

    func test_failureHUD_doubleLengthPseudolanguage_keepsHostTexts() {
        let arguments = Launch.swiftUI + ["--host-texts", "-NSDoubleLocalizedStrings", "YES"]
        let loadingApp = launchExample(arguments)
        loadingApp.buttons[DemoIdentifier.showLoading].tap()
        let loadingShown = loadingApp.staticTexts[DemoText.Host.loading].waitForExistence(timeout: Wait.screenChange)

        let app = launchExample(arguments)
        app.buttons[DemoIdentifier.showFailure].tap()

        XCTAssertTrue(loadingShown, "the host's loading text is shown as written")
        XCTAssertTrue(
            app.staticTexts[DemoText.Host.title].waitForExistence(timeout: Wait.screenChange),
            "the host's title is shown as written"
        )
        XCTAssertTrue(app.buttons[DemoText.Host.close].exists, "the host's Close text is shown as written")
        XCTAssertTrue(app.buttons[DemoText.Host.retry].exists, "the host's Retry text is shown as written")
    }

    /// The example declares German (`App/de.lproj`): iOS shows a framework's texts in the
    /// language of the app, so in an English-only app a German value in the catalog would not
    /// show and this test could not see it.
    func test_failureHUD_germanPreferred_staysEnglish() {
        let app = launchExample(Launch.swiftUI + ["-AppleLanguages", "(de)", "-AppleLocale", "de_DE"])
        app.buttons[DemoIdentifier.showFailure].tap()

        XCTAssertTrue(
            app.staticTexts["An error has occurred!"].waitForExistence(timeout: Wait.screenChange),
            "the library has English texts only, so a German app shows the English title"
        )
        XCTAssertTrue(app.buttons["Close"].exists, "the Close text stays English")
        XCTAssertTrue(app.buttons["Retry"].exists, "the Retry text stays English")
    }

    func test_failureHUD_rightToLeft_mirrorsTheButtons() {
        let app = launchExample(
            Launch.swiftUI + ["-AppleTextDirection", "YES", "-NSForceRightToLeftWritingDirection", "YES"]
        )
        app.buttons[DemoIdentifier.showFailure].tap()
        let close = app.buttons["Close"]
        let retry = app.buttons["Retry"]
        XCTAssertTrue(close.waitForExistence(timeout: Wait.screenChange), "the failure HUD is shown")

        XCTAssertGreaterThan(close.frame.minX, retry.frame.minX, "in a right-to-left language Close lies right of Retry")
    }

    // MARK: - Helpers

    private func text(beginningWith prefix: String, in app: XCUIApplication) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    private func button(beginningWith prefix: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }
}
