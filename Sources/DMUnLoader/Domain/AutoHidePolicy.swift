//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Which phases hide by themselves once the loading manager's delay has passed: a success
/// and a failure do; the loading phase waits for its result.
package enum AutoHidePolicy {
    package static func hidesAfterDelay(_ phase: HUDPhase) -> Bool {
        switch phase {
        case .success, .failure:
            return true
        case .none, .loading:
            return false
        }
    }
}
