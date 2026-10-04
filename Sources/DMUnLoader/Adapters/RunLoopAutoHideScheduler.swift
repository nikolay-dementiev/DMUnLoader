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

    package func schedule(after delay: Duration, _ hide: @escaping @MainActor () -> Void) -> AnyCancellable {
        Deferred {
            Future<Void, Never> { promise in
                promise(.success(()))
            }
        }
        .delay(for: .seconds(delay.timeInterval), scheduler: RunLoop.main)
        .sink { _ in
            hide()
        }
    }
}
