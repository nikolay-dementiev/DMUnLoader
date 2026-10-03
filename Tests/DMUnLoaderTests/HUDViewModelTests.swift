//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The view model of the HUD view: what it shows comes from the manager whenever it is read,
/// and what a touch does goes through the manager.
@MainActor
final class HUDViewModelTests: XCTestCase {

    func test_showsHUD_followsTheManager_afterTheViewModelWasMade() {
        let (sut, manager) = makeSUT()
        let shownBefore = sut.showsHUD

        manager.showLoading(provider: DefaultDMLoadingViewProvider())

        XCTAssertFalse(shownBefore, "no HUD while the manager has no state")
        XCTAssertTrue(sut.showsHUD, "a HUD once the manager shows the loading state, without a new view model")
    }

    func test_tapped_onASuccess_hidesIt() {
        let (sut, manager) = makeSUT()
        manager.showSuccess("done", provider: DefaultDMLoadingViewProvider())

        sut.tapped()

        XCTAssertEqual(manager.loadableState, .none, "a tap dismisses a success")
    }

    func test_tapped_onAFailure_hidesIt() {
        let (sut, manager) = makeSUT()
        manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider(), onRetry: nil)

        sut.tapped()

        XCTAssertEqual(manager.loadableState, .none, "a tap dismisses a failure")
    }

    func test_tapped_whileLoading_keepsTheLoadingState() {
        let (sut, manager) = makeSUT()
        manager.showLoading(provider: DefaultDMLoadingViewProvider())

        sut.tapped()

        XCTAssertTrue(manager.loadableState.showsHUD, "a tap does not dismiss the loading state")
    }

    func test_closeTapped_onAFailure_hidesIt() {
        let (sut, manager) = makeSUT()
        manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider(), onRetry: nil)

        sut.closeTapped()

        XCTAssertEqual(manager.loadableState, .none, "Close hides the failure")
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: DefaultHUDViewModel<DMLoadingManagerMain>, manager: DMLoadingManagerMain) {
        // A delay no test reaches, so no state hides by itself during a test.
        let manager = DMLoadingManagerMain(
            state: .none,
            settings: StubDMLoadingManagerSettings(autoHideDelay: .seconds(600))
        )
        trackForMemoryLeaks(manager, file: file, line: line)
        return (DefaultHUDViewModel(loadingManager: manager), manager)
    }
}
