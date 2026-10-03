//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The auto-hide of `DMLoadingManagerMain` under the dismissal rules of its settings. The
/// scheduler is a spy, so the tests read what is scheduled and never wait for a clock.
@MainActor
final class DMLoadingManagerDismissalTests: XCTestCase {

    func test_showFailure_withRetry_settingsWithOnlyTheDelay_schedulesThatDelay() {
        let scheduler = AutoHideSchedulerSpy()
        let sut = DMLoadingManagerMain(state: .none, settings: DelayOnlySettings(), autoHideScheduler: scheduler)
        trackForMemoryLeaks(sut)

        sut.showFailure(DMAppError.custom("Lost"), provider: provider, onRetry: DMButtonAction {})

        XCTAssertEqual(
            scheduler.scheduled.map(\.delay),
            [.seconds(7)],
            "a failure with Retry hides after the delay, as before 1.1.0"
        )
    }

    func test_showFailure_withRetry_neverRule_schedulesNoHide() {
        let (sut, scheduler) = makeSUT(rules: DMHUDDismissalRules(failureWithRetry: DMHUDDismissal(autoHide: .never)))

        sut.showFailure(DMAppError.custom("Lost"), provider: provider, onRetry: DMButtonAction {})

        XCTAssertTrue(scheduler.scheduled.isEmpty, "a failure with Retry that never hides by itself stays")
    }

    func test_showSuccess_afterRule_schedulesItsDelay() {
        let (sut, scheduler) = makeSUT(rules: DMHUDDismissalRules(success: DMHUDDismissal(autoHide: .after(.seconds(9)))))

        sut.showSuccess("Saved", provider: provider)

        XCTAssertEqual(scheduler.scheduled.map(\.delay), [.seconds(9)], "a success hides after its own delay")
    }

    func test_showFailure_withoutRetry_afterRule_schedulesItsDelay() {
        let rules = DMHUDDismissalRules(failureWithoutRetry: DMHUDDismissal(autoHide: .after(.seconds(4))))
        let (sut, scheduler) = makeSUT(rules: rules)

        sut.showFailure(DMAppError.custom("Lost"), provider: provider, onRetry: nil)

        XCTAssertEqual(scheduler.scheduled.map(\.delay), [.seconds(4)], "a failure without Retry hides after its own delay")
    }

    func test_init_withAFailureWithRetry_neverRule_schedulesNoHide() {
        let failure = DMLoadableType.failure(
            error: DMAppError.custom("Lost"),
            provider: provider.eraseToAnyViewProvider(),
            onRetry: DMButtonAction {}
        )
        let rules = DMHUDDismissalRules(failureWithRetry: DMHUDDismissal(autoHide: .never))

        let (_, scheduler) = makeSUT(state: failure, rules: rules)

        XCTAssertTrue(scheduler.scheduled.isEmpty, "an initial failure with Retry follows the rules too")
    }

    func test_defaultSettings_storeTheirRules() {
        let rules = DMHUDDismissalRules(success: DMHUDDismissal(cardTapHides: false))

        XCTAssertEqual(
            DMLoadingManagerDefaultSettings().hudDismissal,
            DMHUDDismissalRules(),
            "the default settings keep the rules of 1.0"
        )
        XCTAssertEqual(
            DMLoadingManagerDefaultSettings(hudDismissal: rules).hudDismissal,
            rules,
            "the default settings keep the given rules"
        )
    }

    // MARK: - Helpers

    private let provider = DefaultDMLoadingViewProvider()

    private func makeSUT(
        state: DMLoadableType = .none,
        rules: DMHUDDismissalRules,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: DMLoadingManagerMain, scheduler: AutoHideSchedulerSpy) {
        let scheduler = AutoHideSchedulerSpy()
        let sut = DMLoadingManagerMain(
            state: state,
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(7), hudDismissal: rules),
            autoHideScheduler: scheduler
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, scheduler)
    }
}

/// A settings type as hosts wrote it before 1.1.0: only the delay.
private struct DelayOnlySettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(7)
}
