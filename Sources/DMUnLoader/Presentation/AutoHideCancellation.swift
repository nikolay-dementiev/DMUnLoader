//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// The handle a scheduler returns for a pending auto-hide, so that its owner can stop the hide.
///
/// The scheduler supplies an action that stops the delivery of the hide. That action runs at most
/// once: on `cancel()` or, if the token is never cancelled, when the last reference to the token is
/// released, whichever comes first. A second `cancel()`, or a release after a `cancel()`, does
/// nothing. So an owner that goes away stops the hide it was waiting for, and a scheduler cannot
/// forget either half of that contract.
///
/// The action runs on the thread that calls `cancel()` or drops the last reference. In this library
/// that is the main actor, because the port and the manager that hold the token are `@MainActor`.
package final class AutoHideCancellation {
    private var cancelAction: (() -> Void)?

    /// Creates a token for a delivery that `cancel` stops.
    /// - Parameter cancel: Stops the delivery, and is safe to run once on any thread. It also holds
    ///   whatever the delivery needs to stay alive, because the owner keeps only the token: the
    ///   action is released with the token, or right after it ran.
    package init(_ cancel: @escaping () -> Void) {
        cancelAction = cancel
    }

    /// Runs the action given at creation, the first time only. Later calls do nothing.
    package func cancel() {
        let action = cancelAction
        cancelAction = nil
        action?()
    }

    deinit {
        cancel()
    }
}
