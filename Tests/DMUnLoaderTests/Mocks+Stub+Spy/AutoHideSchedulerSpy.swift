//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import DMUnLoader

/// Records the auto-hides a loading manager schedules, and runs one when a test says that
/// its delay has passed.
@MainActor
final class AutoHideSchedulerSpy: AutoHideScheduler {
    /// One call of `schedule(after:_:)`.
    final class ScheduledHide {
        let delay: Duration
        fileprivate(set) var isCancelled = false
        private let hide: @MainActor () -> Void

        fileprivate init(delay: Duration, hide: @escaping @MainActor () -> Void) {
            self.delay = delay
            self.hide = hide
        }

        /// Runs the hide as the scheduler does once the delay has passed. The real
        /// scheduler never runs a cancelled hide; a test runs one only to check that a late
        /// callback cannot hide a newer state.
        @MainActor
        func runHide() {
            hide()
        }
    }

    private(set) var scheduled: [ScheduledHide] = []

    func schedule(after delay: Duration, _ hide: @escaping @MainActor () -> Void) -> AnyCancellable {
        let scheduledHide = ScheduledHide(delay: delay, hide: hide)
        scheduled.append(scheduledHide)
        return AnyCancellable { [weak scheduledHide] in
            scheduledHide?.isCancelled = true
        }
    }
}
