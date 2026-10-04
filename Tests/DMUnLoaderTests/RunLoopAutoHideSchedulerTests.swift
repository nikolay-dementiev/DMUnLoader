//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import XCTest
import DMUnLoader

/// The scheduler the public initializer of `DMLoadingManagerMain` uses, on the real run
/// loop. Each test bounds time from one side only, so a slow machine cannot fail it.
@MainActor
final class RunLoopAutoHideSchedulerTests: XCTestCase {

    func test_schedule_onceTheDelayHasPassed_runsHideOnce() {
        let sut = makeSUT()
        let hidden = expectation(description: "hide runs once the delay has passed")
        hidden.assertForOverFulfill = true

        let subscription = sut.schedule(after: .milliseconds(50)) {
            hidden.fulfill()
        }

        wait(for: [hidden], timeout: 0.05 + TestTiming.callbackAllowance)
        subscription.cancel()
    }

    func test_schedule_hideNeverRunsBeforeItsDelay() {
        let sut = makeSUT()
        let hidden = expectation(description: "hide runs once the delay has passed")
        let scheduledAt = ProcessInfo.processInfo.systemUptime
        var hiddenAt: TimeInterval?

        let subscription = sut.schedule(after: .milliseconds(200)) {
            hiddenAt = ProcessInfo.processInfo.systemUptime
            hidden.fulfill()
        }

        wait(for: [hidden], timeout: 0.2 + TestTiming.callbackAllowance)
        subscription.cancel()
        let elapsed = (hiddenAt ?? scheduledAt) - scheduledAt
        XCTAssertGreaterThanOrEqual(elapsed, 0.19, "the hide never runs before its delay, to within 10 milliseconds")
    }

    func test_schedule_zeroDelay_runsHideAtOnce() {
        let sut = makeSUT()
        let hidden = expectation(description: "hide runs as soon as the run loop turns")
        hidden.assertForOverFulfill = true
        var returned = false
        var hiddenBeforeReturn = false

        // A turn of the run loop is far below a second, and the default auto-hide is two seconds.
        let subscription = sut.schedule(after: .zero) {
            hiddenBeforeReturn = !returned
            hidden.fulfill()
        }
        returned = true

        wait(for: [hidden], timeout: 1)
        subscription.cancel()
        XCTAssertFalse(hiddenBeforeReturn, "the hide is not delivered before schedule returns, even without a delay")
    }

    func test_schedule_negativeDelay_runsHideAtOnce() {
        let sut = makeSUT()
        let hidden = expectation(description: "hide runs as soon as the run loop turns")
        hidden.assertForOverFulfill = true
        var returned = false
        var hiddenBeforeReturn = false

        let subscription = sut.schedule(after: .seconds(-1)) {
            hiddenBeforeReturn = !returned
            hidden.fulfill()
        }
        returned = true

        wait(for: [hidden], timeout: 1)
        subscription.cancel()
        XCTAssertFalse(hiddenBeforeReturn, "the hide is not delivered before schedule returns, even with a negative delay")
    }

    func test_schedule_cancelledBeforeTheDelay_neverRunsHide() {
        let sut = makeSUT()
        var hiddenRan = false
        let witness = expectation(description: "a later hide runs, so the cancelled deadline has passed")

        let cancelled = sut.schedule(after: .milliseconds(50)) {
            hiddenRan = true
        }
        cancelled.cancel()
        // The witness is due after the cancelled deadline: once it runs, the scheduler has
        // passed that deadline and the cancelled hide has had its chance.
        let later = sut.schedule(after: .milliseconds(150)) {
            witness.fulfill()
        }

        wait(for: [witness], timeout: TestTiming.callbackAllowance)
        later.cancel()
        XCTAssertFalse(hiddenRan, "a cancelled hide never runs, even once its deadline has passed")
    }

    // MARK: - Helpers

    private func makeSUT() -> RunLoopAutoHideScheduler {
        RunLoopAutoHideScheduler()
    }
}
