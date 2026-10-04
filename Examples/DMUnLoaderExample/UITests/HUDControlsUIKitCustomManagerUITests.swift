import XCTest

/// Retry and Close of a failure HUD with real touches, on the UIKit integration with a
/// manager written by the host (`--uikit --custom-manager`). A saved scene session of this
/// mode belongs to `DMSceneDelegateUIKit`, so the class runs apart from the other modes.
@MainActor
final class HUDControlsUIKitCustomManagerUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_failureHUD_uiKitCustomManager_retry_runsTheRetryActionOnly() {
        assertRetryRunsTheRetryActionOnly(launchArguments: Launch.uiKitCustomManager)
    }

    func test_failureHUD_uiKitCustomManager_close_hidesTheHUDOnly() {
        assertCloseHidesTheHUDOnly(launchArguments: Launch.uiKitCustomManager)
    }
}
