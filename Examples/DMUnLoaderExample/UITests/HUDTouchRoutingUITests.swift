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

    func test_idleOverlay_customManager_letsTouchesReachContent() {
        assertIdleOverlayLetsTouchesReachContent(launchArguments: ["--custom-manager"])
    }

    // MARK: - Loading HUD: touches do not reach the content

    func test_loadingHUD_swiftUI_keepsTouchesFromContent() {
        assertLoadingHUDKeepsTouchesFromContent(launchArguments: [])
    }

    func test_loadingHUD_customManager_keepsTouchesFromContent() {
        assertLoadingHUDKeepsTouchesFromContent(launchArguments: ["--custom-manager"])
    }

}
