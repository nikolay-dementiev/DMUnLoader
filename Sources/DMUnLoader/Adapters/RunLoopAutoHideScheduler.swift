//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import Foundation

/// Runs the auto-hide on the main run loop, with the Combine delay that
/// `DMLoadingManagerMain` has always used.
@MainActor
package struct RunLoopAutoHideScheduler: AutoHideScheduler {
    package init() {}

    package func schedule(after delay: Duration, _ hide: @escaping @MainActor () -> Void) -> AutoHideCancellation {
        let subscription = Deferred {
            Future<Void, Never> { promise in
                promise(.success(()))
            }
        }
        .delay(for: .seconds(delay.timeInterval), scheduler: RunLoop.main)
        .sink { _ in
            hide()
        }
        // The action holds the subscription: without it the sink would end when this call returns.
        return AutoHideCancellation(subscription.cancel)
    }
}
