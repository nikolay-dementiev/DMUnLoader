import XCTest

/// The example started with no app delegate of the library: the app owns its manager and
/// gives it to `DMRootLoadingView(manager:content:)`. The same touches as in the other launch
/// modes: with no HUD, with the loading HUD, and on Retry and Close of a failure.
@MainActor
final class InjectedManagerUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_idleOverlay_injected_letsTouchesReachContent() {
        assertIdleOverlayLetsTouchesReachContent(launchArguments: Launch.injected)
    }

    func test_loadingHUD_injected_keepsTouchesFromContent() {
        assertLoadingHUDKeepsTouchesFromContent(launchArguments: Launch.injected)
    }

    func test_failureHUD_injected_retry_runsTheRetryActionOnly() {
        assertRetryRunsTheRetryActionOnly(launchArguments: Launch.injected)
    }

    func test_failureHUD_injected_close_hidesTheHUDOnly() {
        assertCloseHidesTheHUDOnly(launchArguments: Launch.injected)
    }
}
