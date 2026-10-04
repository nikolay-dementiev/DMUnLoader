//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader
import XCTest

/// What a host can use with every loading manager: the default settings, and a failure shown
/// without a retry action.
@MainActor
final class DMLoadingManagerConveniencesTests: XCTestCase {

    func test_showFailure_withoutRetryThroughProtocol_showsFailure() {
        let sut = DMLoadingManagerMain()
        trackForMemoryLeaks(sut)

        showFailureWithoutRetry(on: sut, error: DMAppError.custom("failed"))

        guard case let .failure(error, _, onRetry) = sut.loadableState else {
            return XCTFail("a failure is shown, not \(sut.loadableState.rawValue)")
        }
        XCTAssertEqual(
            String(describing: error),
            String(describing: DMAppError.custom("failed")),
            "the failure shows the given error"
        )
        XCTAssertNil(onRetry, "a failure shown without a retry action has no Retry")
    }

    func test_showFailure_withoutRetryOnAnyManager_callsTheRequirementWithoutRetry() {
        let spy = LoadingManagerSpy()
        let manager: any DMLoadingManager = spy

        manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider())

        XCTAssertEqual(spy.failuresWithRetry, [false], "one failure, without a retry action, through the requirement")
    }

    func test_defaultSettings_withoutADelay_waitTwoSeconds() {
        XCTAssertEqual(DMLoadingManagerDefaultSettings().autoHideDelay, .seconds(2), "the default settings hide after 2 seconds")
    }

    func test_managerMain_init_usesTheDefaultSettings() {
        let settings = DMLoadingManagerMain().settings

        XCTAssertEqual(
            (settings as? DMLoadingManagerDefaultSettings)?.autoHideDelay,
            .seconds(2),
            "a manager made without settings uses the default settings of 2 seconds"
        )
    }

    // MARK: - Helpers

    /// Shows a failure the way generic host code does: through the protocol only.
    private func showFailureWithoutRetry<LM: DMLoadingManager>(on manager: LM, error: any Error) {
        manager.showFailure(error, provider: DefaultDMLoadingViewProvider())
    }
}

/// Records whether each failure a manager is asked to show has a retry action.
@MainActor
private final class LoadingManagerSpy: DMLoadingManager {
    let loadableState: DMLoadableType = .none
    let settings: any DMLoadingManagerSettings = SpySettings()
    private(set) var failuresWithRetry: [Bool] = []

    init() {}

    func showLoading<PR: DMLoadingViewProvider>(provider: PR) {}

    func showSuccess<PR: DMLoadingViewProvider>(_ message: any DMLoadableTypeSuccess, provider: PR) {}

    func showFailure<PR: DMLoadingViewProvider>(_ error: any Error, provider: PR, onRetry: (any DMAction)?) {
        failuresWithRetry.append(onRetry != nil)
    }

    func hide() {}
}

private struct SpySettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(2)
}
