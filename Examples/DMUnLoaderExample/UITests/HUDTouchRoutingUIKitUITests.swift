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
}
