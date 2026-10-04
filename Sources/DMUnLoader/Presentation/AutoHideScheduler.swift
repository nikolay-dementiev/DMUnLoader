//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine

/// Runs the auto-hide of a loading manager once its delay has passed.
///
/// The loading manager depends on this port instead of a clock, so a test decides when
/// the delay has passed.
@MainActor
package protocol AutoHideScheduler {
    /// Calls `hide` on the main actor once `delay` has passed, never from within this call.
    /// Cancelling or releasing the returned value before then keeps `hide` from being
    /// called. The loading manager also ignores a `hide` that arrives after it cancelled.
    func schedule(after delay: Duration, _ hide: @escaping @MainActor () -> Void) -> AnyCancellable
}
