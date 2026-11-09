//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Runs the auto-hide of a loading manager once its delay has passed.
///
/// The loading manager depends on this port instead of a clock, so a test decides when
/// the delay has passed.
///
/// A conformer returns an `AutoHideCancellation` whose action does what the token cannot do
/// itself:
/// - it stops the delivery of `hide`;
/// - it keeps alive whatever the delivery needs, because the manager keeps only the token and
///   the action is released with it;
/// - it is safe to run once on any thread.
///
/// The token runs the action at most once, on `cancel()` or on the last release, so a conformer
/// does not repeat either of those.
@MainActor
package protocol AutoHideScheduler {
    /// Calls `hide` on the main actor once `delay` has passed, never from within this call.
    /// Cancelling or releasing the returned token before then keeps `hide` from being called.
    /// The loading manager also ignores a `hide` that arrives after it cancelled.
    func schedule(after delay: Duration, _ hide: @escaping @MainActor () -> Void) -> AutoHideCancellation
}
