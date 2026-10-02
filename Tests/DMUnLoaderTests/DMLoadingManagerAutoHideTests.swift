//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import XCTest
import DMUnLoader

/// The auto-hide and the published state of `DMLoadingManagerMain`. The scheduler is a
/// spy, so the tests decide when a delay has passed and never wait for a clock.
@MainActor
final class DMLoadingManagerAutoHideTests: XCTestCase {

    // MARK: - Deadlines

    func test_showSuccess_whenShown_schedulesOneHideAfterTheSettingsDelay() {
        let (sut, scheduler) = makeSUT(autoHideDelay: .seconds(7))

        sut.showSuccess("Saved", provider: provider)

        XCTAssertEqual(scheduler.scheduled.map(\.delay), [.seconds(7)], "one hide, after the delay of the settings")
        XCTAssertEqual(sut.loadableState.rawValue, "Success: `Saved`", "the success stays until the delay has passed")
        scheduler.scheduled[0].runHide()
        XCTAssertEqual(sut.loadableState.rawValue, "None", "once the delay has passed, the success is hidden")
    }

    func test_showFailure_whenShown_schedulesOneHideAfterTheSettingsDelay() {
        let (sut, scheduler) = makeSUT(autoHideDelay: .seconds(7))

        sut.showFailure(DMAppError.custom("Lost"), provider: provider, onRetry: nil)

        XCTAssertEqual(scheduler.scheduled.map(\.delay), [.seconds(7)], "one hide, after the delay of the settings")
        scheduler.scheduled[0].runHide()
        XCTAssertEqual(sut.loadableState.rawValue, "None", "once the delay has passed, the failure is hidden")
    }

    func test_showLoading_whenShown_schedulesNoHide() {
        let (sut, scheduler) = makeSUT()

        sut.showLoading(provider: provider)

        XCTAssertTrue(scheduler.scheduled.isEmpty, "a loading HUD stays until the host replaces it")
    }

    func test_init_withSuccessOrFailure_schedulesTheHideAtOnce() {
        let success = makeSUT(state: .success("Saved", provider: provider.eraseToAnyViewProvider()))
        let failure = makeSUT(state: .failure(error: DMAppError.custom("Lost"), provider: provider.eraseToAnyViewProvider()))

        XCTAssertEqual(success.scheduler.scheduled.count, 1, "an initial success is hidden after the delay")
        XCTAssertEqual(failure.scheduler.scheduled.count, 1, "an initial failure is hidden after the delay")
        success.scheduler.scheduled[0].runHide()
        failure.scheduler.scheduled[0].runHide()
        XCTAssertEqual(success.sut.loadableState.rawValue, "None", "the initial success is hidden")
        XCTAssertEqual(failure.sut.loadableState.rawValue, "None", "the initial failure is hidden")
    }

    func test_init_withLoadingOrNone_schedulesNoHide() {
        let loading = makeSUT(state: .loading(provider: provider.eraseToAnyViewProvider()))
        let idle = makeSUT(state: .none)

        XCTAssertTrue(loading.scheduler.scheduled.isEmpty, "an initial loading state is never hidden by a timer")
        XCTAssertTrue(idle.scheduler.scheduled.isEmpty, "with nothing shown there is nothing to hide")
    }

    // MARK: - Cancellation

    func test_showLoading_afterSuccess_cancelsTheScheduledHide() {
        let (sut, scheduler) = makeSUT()
        sut.showSuccess("Saved", provider: provider)

        sut.showLoading(provider: provider)

        XCTAssertTrue(scheduler.scheduled[0].isCancelled, "the hide of the success no longer applies")
        XCTAssertEqual(scheduler.scheduled.count, 1, "loading schedules no hide of its own")
    }

    func test_hide_afterFailure_cancelsTheScheduledHide() {
        let (sut, scheduler) = makeSUT()
        sut.showFailure(DMAppError.custom("Lost"), provider: provider, onRetry: nil)

        sut.hide()

        XCTAssertTrue(scheduler.scheduled[0].isCancelled, "the failure was hidden by hand: its timer is cancelled")
        XCTAssertEqual(sut.loadableState.rawValue, "None", "hide leaves nothing shown")
    }

    func test_showSuccess_afterSuccess_replacesTheHideWithAFullDelay() {
        let (sut, scheduler) = makeSUT(autoHideDelay: .seconds(7))
        sut.showSuccess("Saved", provider: provider)

        sut.showSuccess("Saved again", provider: provider)

        XCTAssertEqual(scheduler.scheduled.map(\.delay), [.seconds(7), .seconds(7)], "the second success gets the full delay")
        XCTAssertTrue(scheduler.scheduled[0].isCancelled, "the hide of the first success is cancelled")
        XCTAssertFalse(scheduler.scheduled[1].isCancelled, "the hide of the second success stands")
    }

    func test_lateHide_afterTheStateWasReplaced_keepsTheNewerState() {
        let (sut, scheduler) = makeSUT()
        sut.showSuccess("Saved", provider: provider)
        sut.showFailure(DMAppError.custom("Lost"), provider: provider, onRetry: nil)

        // The hide of the success was cancelled; a scheduler may still deliver it late.
        scheduler.scheduled[0].runHide()

        guard case .failure = sut.loadableState else {
            return XCTFail("a late hide of the replaced success hid the newer failure: \(sut.loadableState.rawValue)")
        }
    }

    // MARK: - Payloads

    func test_showSuccess_whenShown_keepsTheMessage() {
        let (sut, _) = makeSUT()

        sut.showSuccess("Saved", provider: provider)

        guard case let .success(message, _) = sut.loadableState else {
            return XCTFail("the state is a success, not \(sut.loadableState.rawValue)")
        }
        XCTAssertEqual(message.description, "Saved", "the success carries the message it was shown with")
    }

    func test_showFailure_whenShown_keepsTheErrorAndTheRetryAction() {
        let (sut, _) = makeSUT()
        let error = NSError(domain: "Test", code: 7)
        let retry = DMButtonAction {}

        sut.showFailure(error, provider: provider, onRetry: retry)

        guard case let .failure(shownError, _, shownRetry) = sut.loadableState else {
            return XCTFail("the state is a failure, not \(sut.loadableState.rawValue)")
        }
        XCTAssertTrue((shownError as NSError) === error, "the failure carries the very error it was shown with")
        XCTAssertEqual(shownRetry?.id, retry.id, "the failure carries the retry action it was shown with")
    }

    // MARK: - Published state

    func test_loadableStatePublisher_hide_emitsNoneAfterTheCurrentState() {
        let (sut, _) = makeSUT()
        sut.showSuccess("Saved", provider: provider)
        var emitted: [String] = []
        let subscription = sut.$loadableState.sink { emitted.append($0.rawValue) }

        sut.hide()

        XCTAssertEqual(emitted, ["Success: `Saved`", "None"], "a subscriber gets the current state, then each new one")
        subscription.cancel()
    }

    func test_objectWillChange_showFailure_firesOnceBeforeTheStateChanges() {
        let (sut, _) = makeSUT()
        var stateWhenNotified: [String] = []
        let subscription = sut.objectWillChange.sink { stateWhenNotified.append(sut.loadableState.rawValue) }

        sut.showFailure(DMAppError.custom("Lost"), provider: provider, onRetry: nil)

        XCTAssertEqual(stateWhenNotified, ["None"], "observers hear once, before the state changes")
        subscription.cancel()
    }

    // MARK: - Helpers

    private let provider = DefaultDMLoadingViewProvider()

    private func makeSUT(
        state: DMLoadableType = .none,
        autoHideDelay: Duration = .seconds(2),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: DMLoadingManagerMain, scheduler: AutoHideSchedulerSpy) {
        let scheduler = AutoHideSchedulerSpy()
        let sut = DMLoadingManagerMain(
            state: state,
            settings: AutoHideSettings(autoHideDelay: autoHideDelay),
            autoHideScheduler: scheduler
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, scheduler)
    }
}

private struct AutoHideSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration
}
