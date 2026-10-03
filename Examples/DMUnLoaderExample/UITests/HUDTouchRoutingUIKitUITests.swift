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
}
