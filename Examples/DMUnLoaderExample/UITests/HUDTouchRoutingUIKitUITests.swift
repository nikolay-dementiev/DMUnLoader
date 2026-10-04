import XCTest

/// Touch routing with real touches on the UIKit integration (`--uikit`). A saved scene
/// session of this mode belongs to `DMSceneDelegateTypeUIKit`, so the class runs apart from
/// the other modes.
@MainActor
final class HUDTouchRoutingUIKitUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_idleOverlay_uiKit_letsTouchesReachContent() {
        assertIdleOverlayLetsTouchesReachContent(launchArguments: ["--uikit"])
    }

    func test_loadingHUD_uiKit_keepsTouchesFromContent() {
        assertLoadingHUDKeepsTouchesFromContent(launchArguments: ["--uikit"])
    }

    func test_loadingHUD_uiKit_isShownInOneHUDWindow() {
        let app = launchExample(["--uikit", "--accessibility-tree"])
        XCTAssertTrue(
            app.buttons[DemoIdentifier.content].waitForExistence(timeout: Wait.launch),
            "the demo screen is shown"
        )
        app.buttons[DemoIdentifier.showLoading].tap()
        XCTAssertTrue(
            app.staticTexts["Loading..."].waitForExistence(timeout: Wait.screenChange),
            "the loading HUD shows its text before the HUD windows are counted"
        )

        let windowCount = app.staticTexts[DemoIdentifier.hudWindowCount]
        XCTAssertTrue(
            windowCount.waitForExistence(timeout: Wait.launch),
            "the counters window reports the HUD windows"
        )
        XCTAssertTrue(
            wait(
                for: NSPredicate(format: "label == %@", DemoText.hudWindows(1)),
                on: windowCount,
                timeout: Wait.screenChange
            ),
            "the UIKit route shows the loading HUD in one HUD window"
        )
    }

    /// The scene delegate sets its loading manager before it builds the root view controller, so a
    /// root view controller that reads the manager through the delegate finds it there.
    func test_uiKitRootView_whileItIsBuilt_theDelegateHoldsTheManager() {
        let app = launchExample(["--uikit"])
        let witness = app.staticTexts[DemoIdentifier.constructionWitness]
        XCTAssertTrue(
            witness.waitForExistence(timeout: Wait.launch),
            "the counters window reports what the delegate held while the root view was built"
        )

        XCTAssertTrue(
            wait(
                for: NSPredicate(format: "label == %@", DemoText.delegateHoldsTheManager(true)),
                on: witness,
                timeout: Wait.screenChange
            ),
            "the scene delegate holds its loading manager while the root view controller is built"
        )
    }
}
