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
        let sut = RunLoopAutoHideScheduler()
        let hidden = expectation(description: "hide runs once the delay has passed")
        hidden.assertForOverFulfill = true

        let subscription = sut.schedule(after: .milliseconds(50)) {
            hidden.fulfill()
        }

        wait(for: [hidden], timeout: 0.05 + TestTiming.callbackAllowance)
        subscription.cancel()
    }

    func test_schedule_cancelledBeforeTheDelay_neverRunsHide() {
        let sut = RunLoopAutoHideScheduler()
        let hidden = expectation(description: "a cancelled hide never runs")
        hidden.isInverted = true

        let subscription = sut.schedule(after: .milliseconds(50)) {
            hidden.fulfill()
        }
        subscription.cancel()

        wait(for: [hidden], timeout: 0.5)
    }
}
