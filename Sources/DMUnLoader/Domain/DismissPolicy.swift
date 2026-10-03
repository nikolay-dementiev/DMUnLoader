//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Which phases a tap on the HUD dismisses: every phase but loading, which waits for its
/// result.
package enum DismissPolicy {
    package static func tapDismisses(_ phase: HUDPhase) -> Bool {
        switch phase {
        case .none, .success, .failure:
            return true
        case .loading:
            return false
        }
    }
}
