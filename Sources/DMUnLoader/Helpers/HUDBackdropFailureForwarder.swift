//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMVariableBlurView

/// Turns the handler of the host into the handler of DMVariableBlurView.
package enum HUDBackdropFailureForwarder {
    /// The handler for a blur view that reports to `host`, or `nil` when the host has none, so that
    /// the blur view keeps writing its own line to the log.
    @MainActor
    package static func leafHandler(
        for host: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?
    ) -> (@MainActor (DMVariableBlurError) -> Void)? {
        guard let host else {
            return nil
        }
        return { error in
            host(DMHUDBackdropFailure(error))
        }
    }
}
