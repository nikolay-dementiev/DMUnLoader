//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// The phase of a HUD, without what it shows. The state a loading manager holds is
/// `DMLoadableType`, which keeps the error, the payload and the view provider; its phase is
/// what the policies decide on.
package enum HUDPhase: Equatable, Sendable {
    case none
    case loading
    case success
    case failure

    /// Whether the phase shows a HUD, and so whether the HUD window takes the touches.
    package var showsHUD: Bool {
        switch self {
        case .none:
            return false
        case .loading, .success, .failure:
            return true
        }
    }
}
